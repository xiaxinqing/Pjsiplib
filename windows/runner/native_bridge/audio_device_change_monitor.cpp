#include "audio_device_change_monitor.h"

#include <functiondiscoverykeys_devpkey.h>

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
