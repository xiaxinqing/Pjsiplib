#include "audio_device_change_monitor.h"

#include <utility>

struct LinuxAudioDeviceChangeMonitor::ServerQuery {
  LinuxAudioDeviceChangeMonitor* monitor;
  bool done = false;
  std::string input_name;
  std::string output_name;
};

struct LinuxAudioDeviceChangeMonitor::EndpointQuery {
  LinuxAudioDeviceChangeMonitor* monitor;
  bool done = false;
  LinuxAudioEndpointInfo endpoint;
};

LinuxAudioDeviceChangeMonitor::LinuxAudioDeviceChangeMonitor(
    std::function<void()> on_devices_changed)
    : on_devices_changed_(std::move(on_devices_changed)) {}

LinuxAudioDeviceChangeMonitor::~LinuxAudioDeviceChangeMonitor() {
  Stop();
}

bool LinuxAudioDeviceChangeMonitor::Start() {
  if (context_ != nullptr && mainloop_started_) {
    return true;
  }

  mainloop_ = pa_threaded_mainloop_new();
  if (mainloop_ == nullptr) {
    return false;
  }

  context_ = pa_context_new(pa_threaded_mainloop_get_api(mainloop_), "VPhone");
  if (context_ == nullptr) {
    Stop();
    return false;
  }
  pa_context_set_state_callback(context_, ContextStateCallback, this);

  if (pa_threaded_mainloop_start(mainloop_) < 0) {
    Stop();
    return false;
  }
  mainloop_started_ = true;

  pa_threaded_mainloop_lock(mainloop_);
  if (pa_context_connect(context_, nullptr, PA_CONTEXT_NOFLAGS, nullptr) < 0) {
    pa_threaded_mainloop_unlock(mainloop_);
    Stop();
    return false;
  }

  while (true) {
    const pa_context_state_t state = pa_context_get_state(context_);
    if (state == PA_CONTEXT_READY) {
      break;
    }
    if (!PA_CONTEXT_IS_GOOD(state)) {
      pa_threaded_mainloop_unlock(mainloop_);
      Stop();
      return false;
    }
    pa_threaded_mainloop_wait(mainloop_);
  }

  pa_context_set_subscribe_callback(context_, SubscribeCallback, this);
  pa_operation* operation = pa_context_subscribe(
      context_,
      static_cast<pa_subscription_mask_t>(
          PA_SUBSCRIPTION_MASK_SERVER | PA_SUBSCRIPTION_MASK_SINK |
          PA_SUBSCRIPTION_MASK_SOURCE),
      nullptr, nullptr);
  if (operation != nullptr) {
    pa_operation_unref(operation);
  }
  pa_threaded_mainloop_unlock(mainloop_);
  return true;
}

void LinuxAudioDeviceChangeMonitor::Stop() {
  if (mainloop_ != nullptr && mainloop_started_) {
    pa_threaded_mainloop_lock(mainloop_);
    if (context_ != nullptr) {
      pa_context_set_subscribe_callback(context_, nullptr, nullptr);
      pa_context_set_state_callback(context_, nullptr, nullptr);
      pa_context_disconnect(context_);
    }
    pa_threaded_mainloop_unlock(mainloop_);
    pa_threaded_mainloop_stop(mainloop_);
  }
  mainloop_started_ = false;

  if (context_ != nullptr) {
    pa_context_unref(context_);
    context_ = nullptr;
  }
  if (mainloop_ != nullptr) {
    pa_threaded_mainloop_free(mainloop_);
    mainloop_ = nullptr;
  }
}

bool LinuxAudioDeviceChangeMonitor::GetCurrentAudioRoute(
    LinuxSystemAudioRouteInfo* route) {
  if (route == nullptr || mainloop_ == nullptr || context_ == nullptr ||
      !mainloop_started_) {
    return false;
  }

  *route = LinuxSystemAudioRouteInfo{};
  pa_threaded_mainloop_lock(mainloop_);
  if (!IsContextReadyLocked()) {
    pa_threaded_mainloop_unlock(mainloop_);
    return false;
  }

  std::string input_name;
  std::string output_name;
  const bool server_query_succeeded =
      ReadServerDefaultsLocked(&input_name, &output_name);
  if (server_query_succeeded && !input_name.empty()) {
    ReadSourceLocked(input_name, &route->input);
  }
  if (server_query_succeeded && !output_name.empty()) {
    ReadSinkLocked(output_name, &route->output);
  }
  pa_threaded_mainloop_unlock(mainloop_);
  return server_query_succeeded;
}

void LinuxAudioDeviceChangeMonitor::ContextStateCallback(pa_context*,
                                                          void* user_data) {
  auto* monitor = static_cast<LinuxAudioDeviceChangeMonitor*>(user_data);
  pa_threaded_mainloop_signal(monitor->mainloop_, 0);
}

void LinuxAudioDeviceChangeMonitor::SubscribeCallback(
    pa_context*,
    pa_subscription_event_type_t,
    uint32_t,
    void* user_data) {
  auto* monitor = static_cast<LinuxAudioDeviceChangeMonitor*>(user_data);
  if (monitor->on_devices_changed_) {
    monitor->on_devices_changed_();
  }
}

void LinuxAudioDeviceChangeMonitor::ServerInfoCallback(
    pa_context*, const pa_server_info* info, void* user_data) {
  auto* query = static_cast<ServerQuery*>(user_data);
  if (info != nullptr) {
    if (info->default_source_name != nullptr) {
      query->input_name = info->default_source_name;
    }
    if (info->default_sink_name != nullptr) {
      query->output_name = info->default_sink_name;
    }
  }
  query->done = true;
  pa_threaded_mainloop_signal(query->monitor->mainloop_, 0);
}

void LinuxAudioDeviceChangeMonitor::SinkInfoCallback(
    pa_context*, const pa_sink_info* info, int eol, void* user_data) {
  auto* query = static_cast<EndpointQuery*>(user_data);
  if (info != nullptr && eol == 0) {
    query->endpoint.id = info->name == nullptr ? "" : info->name;
    query->endpoint.name =
        info->description == nullptr ? query->endpoint.id : info->description;
    query->endpoint.available = !query->endpoint.id.empty();
  }
  if (eol != 0) {
    query->done = true;
    pa_threaded_mainloop_signal(query->monitor->mainloop_, 0);
  }
}

void LinuxAudioDeviceChangeMonitor::SourceInfoCallback(
    pa_context*, const pa_source_info* info, int eol, void* user_data) {
  auto* query = static_cast<EndpointQuery*>(user_data);
  if (info != nullptr && eol == 0) {
    query->endpoint.id = info->name == nullptr ? "" : info->name;
    query->endpoint.name =
        info->description == nullptr ? query->endpoint.id : info->description;
    query->endpoint.available = !query->endpoint.id.empty();
  }
  if (eol != 0) {
    query->done = true;
    pa_threaded_mainloop_signal(query->monitor->mainloop_, 0);
  }
}

bool LinuxAudioDeviceChangeMonitor::IsContextReadyLocked() const {
  return context_ != nullptr &&
         pa_context_get_state(context_) == PA_CONTEXT_READY;
}

bool LinuxAudioDeviceChangeMonitor::ReadServerDefaultsLocked(
    std::string* input_name, std::string* output_name) {
  ServerQuery query;
  query.monitor = this;
  pa_operation* operation =
      pa_context_get_server_info(context_, ServerInfoCallback, &query);
  if (operation == nullptr) {
    return false;
  }
  while (!query.done && IsContextReadyLocked()) {
    pa_threaded_mainloop_wait(mainloop_);
  }
  if (!query.done) {
    pa_operation_cancel(operation);
  }
  pa_operation_unref(operation);
  if (!query.done) {
    return false;
  }
  *input_name = std::move(query.input_name);
  *output_name = std::move(query.output_name);
  return true;
}

bool LinuxAudioDeviceChangeMonitor::ReadSinkLocked(
    const std::string& name, LinuxAudioEndpointInfo* endpoint) {
  EndpointQuery query;
  query.monitor = this;
  pa_operation* operation = pa_context_get_sink_info_by_name(
      context_, name.c_str(), SinkInfoCallback, &query);
  if (operation == nullptr) {
    return false;
  }
  while (!query.done && IsContextReadyLocked()) {
    pa_threaded_mainloop_wait(mainloop_);
  }
  if (!query.done) {
    pa_operation_cancel(operation);
  }
  pa_operation_unref(operation);
  if (!query.done) {
    return false;
  }
  *endpoint = std::move(query.endpoint);
  return endpoint->available;
}

bool LinuxAudioDeviceChangeMonitor::ReadSourceLocked(
    const std::string& name, LinuxAudioEndpointInfo* endpoint) {
  EndpointQuery query;
  query.monitor = this;
  pa_operation* operation = pa_context_get_source_info_by_name(
      context_, name.c_str(), SourceInfoCallback, &query);
  if (operation == nullptr) {
    return false;
  }
  while (!query.done && IsContextReadyLocked()) {
    pa_threaded_mainloop_wait(mainloop_);
  }
  if (!query.done) {
    pa_operation_cancel(operation);
  }
  pa_operation_unref(operation);
  if (!query.done) {
    return false;
  }
  *endpoint = std::move(query.endpoint);
  return endpoint->available;
}
