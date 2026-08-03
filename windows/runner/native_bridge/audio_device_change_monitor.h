#ifndef RUNNER_NATIVE_BRIDGE_AUDIO_DEVICE_CHANGE_MONITOR_H_
#define RUNNER_NATIVE_BRIDGE_AUDIO_DEVICE_CHANGE_MONITOR_H_

#include <windows.h>

#include <atomic>
#include <mmdeviceapi.h>

// IMMNotificationClient 回调可能运行在 COM 工作线程。这里通过窗口私有消息转发，
// 确保 Flutter MethodChannel 始终在窗口线程中调用。
constexpr UINT kAudioDeviceChangedMessage = WM_APP + 42;

/// 监听 Windows Core Audio 端点变化，不直接操作 PJSIP。
///
/// 所有者持有一个 COM 引用，IMMDeviceEnumerator 在回调注册期间可能再持有一个。
/// 使用标准 AddRef/Release 语义，可确保双方释放引用前对象始终有效。
class AudioDeviceChangeMonitor final : public IMMNotificationClient {
 public:
  AudioDeviceChangeMonitor();

  bool Start(HWND window);
  void Stop();

  // IUnknown 接口实现。
  ULONG STDMETHODCALLTYPE AddRef() override;
  ULONG STDMETHODCALLTYPE Release() override;
  HRESULT STDMETHODCALLTYPE QueryInterface(REFIID iid,
                                           void** object) override;

  // IMMNotificationClient 音频设备变化回调。
  HRESULT STDMETHODCALLTYPE OnDefaultDeviceChanged(
      EDataFlow flow, ERole role, LPCWSTR device_id) override;
  HRESULT STDMETHODCALLTYPE OnDeviceAdded(LPCWSTR device_id) override;
  HRESULT STDMETHODCALLTYPE OnDeviceRemoved(LPCWSTR device_id) override;
  HRESULT STDMETHODCALLTYPE OnDeviceStateChanged(LPCWSTR device_id,
                                                 DWORD new_state) override;
  HRESULT STDMETHODCALLTYPE OnPropertyValueChanged(
      LPCWSTR device_id, const PROPERTYKEY key) override;

 private:
  ~AudioDeviceChangeMonitor();

  void NotifyDevicesChanged();

  std::atomic<ULONG> reference_count_{1};
  IMMDeviceEnumerator* enumerator_ = nullptr;
  std::atomic<HWND> window_{nullptr};
  std::atomic_bool monitoring_{false};
};

#endif  // RUNNER_NATIVE_BRIDGE_AUDIO_DEVICE_CHANGE_MONITOR_H_
