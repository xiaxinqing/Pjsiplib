#include "audio_device_change_monitor.h"

#include <functiondiscoverykeys_devpkey.h>
#include <propvarutil.h>
#include <propsys.h>

namespace {

std::string Utf8FromWide(const wchar_t* value) {
  if (value == nullptr || *value == L'\0') {
    return {};
  }
  const int size = ::WideCharToMultiByte(CP_UTF8, 0, value, -1, nullptr, 0,
                                         nullptr, nullptr);
  if (size <= 1) {
    return {};
  }
  std::string result(static_cast<size_t>(size), '\0');
  ::WideCharToMultiByte(CP_UTF8, 0, value, -1, result.data(), size, nullptr,
                        nullptr);
  result.pop_back();
  return result;
}

}  // namespace

AudioDeviceChangeMonitor::AudioDeviceChangeMonitor() = default;

AudioDeviceChangeMonitor::~AudioDeviceChangeMonitor() {
  Stop();
}

bool AudioDeviceChangeMonitor::Start(HWND window) {
  window_.store(window);
  if (monitoring_.load()) {
    return true;
  }

  HRESULT result = ::CoCreateInstance(__uuidof(MMDeviceEnumerator), nullptr,
                                      CLSCTX_ALL,
                                      IID_PPV_ARGS(&enumerator_));
  if (FAILED(result) || enumerator_ == nullptr) {
    enumerator_ = nullptr;
    return false;
  }

  result = enumerator_->RegisterEndpointNotificationCallback(this);
  if (FAILED(result)) {
    enumerator_->Release();
    enumerator_ = nullptr;
    return false;
  }

  monitoring_.store(true);
  return true;
}

void AudioDeviceChangeMonitor::Stop() {
  if (enumerator_ != nullptr) {
    if (monitoring_.load()) {
      enumerator_->UnregisterEndpointNotificationCallback(this);
    }
    enumerator_->Release();
    enumerator_ = nullptr;
  }
  monitoring_.store(false);
  window_.store(nullptr);
}

bool AudioDeviceChangeMonitor::GetCurrentAudioRoute(
    SystemAudioRouteInfo* route) const {
  if (route == nullptr || enumerator_ == nullptr) {
    return false;
  }
  *route = SystemAudioRouteInfo{};
  const bool has_input = ReadDefaultEndpoint(eCapture, &route->input);
  const bool has_output = ReadDefaultEndpoint(eRender, &route->output);
  return has_input || has_output;
}

bool AudioDeviceChangeMonitor::ReadDefaultEndpoint(
    EDataFlow flow, AudioEndpointInfo* endpoint) const {
  if (endpoint == nullptr || enumerator_ == nullptr) {
    return false;
  }

  IMMDevice* device = nullptr;
  HRESULT result =
      enumerator_->GetDefaultAudioEndpoint(flow, eConsole, &device);
  if (FAILED(result) || device == nullptr) {
    return false;
  }

  LPWSTR endpoint_id = nullptr;
  result = device->GetId(&endpoint_id);
  if (FAILED(result) || endpoint_id == nullptr) {
    device->Release();
    return false;
  }

  IPropertyStore* properties = nullptr;
  result = device->OpenPropertyStore(STGM_READ, &properties);
  if (FAILED(result) || properties == nullptr) {
    ::CoTaskMemFree(endpoint_id);
    device->Release();
    return false;
  }

  PROPVARIANT friendly_name;
  ::PropVariantInit(&friendly_name);
  result = properties->GetValue(PKEY_Device_FriendlyName, &friendly_name);

  endpoint->id = Utf8FromWide(endpoint_id);
  if (SUCCEEDED(result) && friendly_name.vt == VT_LPWSTR) {
    endpoint->name = Utf8FromWide(friendly_name.pwszVal);
  }
  if (endpoint->name.empty()) {
    endpoint->name = endpoint->id;
  }
  endpoint->available = !endpoint->id.empty() && !endpoint->name.empty();

  ::PropVariantClear(&friendly_name);
  properties->Release();
  ::CoTaskMemFree(endpoint_id);
  device->Release();
  return endpoint->available;
}

ULONG STDMETHODCALLTYPE AudioDeviceChangeMonitor::AddRef() {
  return ++reference_count_;
}

ULONG STDMETHODCALLTYPE AudioDeviceChangeMonitor::Release() {
  const ULONG references = --reference_count_;
  if (references == 0) {
    delete this;
  }
  return references;
}

HRESULT STDMETHODCALLTYPE AudioDeviceChangeMonitor::QueryInterface(
    REFIID iid, void** object) {
  if (object == nullptr) {
    return E_POINTER;
  }

  if (iid == __uuidof(IUnknown) || iid == __uuidof(IMMNotificationClient)) {
    *object = static_cast<IMMNotificationClient*>(this);
    AddRef();
    return S_OK;
  }

  *object = nullptr;
  return E_NOINTERFACE;
}

HRESULT STDMETHODCALLTYPE AudioDeviceChangeMonitor::OnDefaultDeviceChanged(
    EDataFlow, ERole, LPCWSTR) {
  NotifyDevicesChanged();
  return S_OK;
}

HRESULT STDMETHODCALLTYPE AudioDeviceChangeMonitor::OnDeviceAdded(LPCWSTR) {
  NotifyDevicesChanged();
  return S_OK;
}

HRESULT STDMETHODCALLTYPE AudioDeviceChangeMonitor::OnDeviceRemoved(LPCWSTR) {
  NotifyDevicesChanged();
  return S_OK;
}

HRESULT STDMETHODCALLTYPE AudioDeviceChangeMonitor::OnDeviceStateChanged(
    LPCWSTR, DWORD) {
  NotifyDevicesChanged();
  return S_OK;
}

HRESULT STDMETHODCALLTYPE AudioDeviceChangeMonitor::OnPropertyValueChanged(
    LPCWSTR, const PROPERTYKEY) {
  NotifyDevicesChanged();
  return S_OK;
}

void AudioDeviceChangeMonitor::NotifyDevicesChanged() {
  const HWND window = window_.load();
  if (monitoring_.load() && window != nullptr) {
    ::PostMessage(window, kAudioDeviceChangedMessage, 0, 0);
  }
}
