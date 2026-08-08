#ifndef FLUTTER_AUDIO_DEVICE_CHANGE_MONITOR_H_
#define FLUTTER_AUDIO_DEVICE_CHANGE_MONITOR_H_

#include <pulse/pulseaudio.h>
#include <pulse/thread-mainloop.h>

#include <functional>
#include <string>

struct LinuxAudioEndpointInfo {
  bool available = false;
  std::string id;
  std::string name;
};

struct LinuxSystemAudioRouteInfo {
  LinuxAudioEndpointInfo input;
  LinuxAudioEndpointInfo output;
};

/// 通过 PulseAudio API 读取和监听 Linux 默认音频端点。
///
/// PipeWire 桌面通常提供 PulseAudio 兼容服务，因此不需要再维护一套 PipeWire
/// 专用实现。该类只负责系统路由，不直接调用 PJSIP。
class LinuxAudioDeviceChangeMonitor {
 public:
  explicit LinuxAudioDeviceChangeMonitor(
      std::function<void()> on_devices_changed);
  ~LinuxAudioDeviceChangeMonitor();

  bool Start();
  void Stop();
  bool GetCurrentAudioRoute(LinuxSystemAudioRouteInfo* route);

 private:
  struct ServerQuery;
  struct EndpointQuery;

  static void ContextStateCallback(pa_context* context, void* user_data);
  static void SubscribeCallback(pa_context* context,
                                pa_subscription_event_type_t event_type,
                                uint32_t index,
                                void* user_data);
  static void ServerInfoCallback(pa_context* context,
                                 const pa_server_info* info,
                                 void* user_data);
  static void SinkInfoCallback(pa_context* context,
                               const pa_sink_info* info,
                               int eol,
                               void* user_data);
  static void SourceInfoCallback(pa_context* context,
                                 const pa_source_info* info,
                                 int eol,
                                 void* user_data);

  bool IsContextReadyLocked() const;
  bool ReadServerDefaultsLocked(std::string* input_name,
                                std::string* output_name);
  bool ReadSinkLocked(const std::string& name,
                      LinuxAudioEndpointInfo* endpoint);
  bool ReadSourceLocked(const std::string& name,
                        LinuxAudioEndpointInfo* endpoint);

  std::function<void()> on_devices_changed_;
  pa_threaded_mainloop* mainloop_ = nullptr;
  pa_context* context_ = nullptr;
  bool mainloop_started_ = false;
};

#endif  // FLUTTER_AUDIO_DEVICE_CHANGE_MONITOR_H_
