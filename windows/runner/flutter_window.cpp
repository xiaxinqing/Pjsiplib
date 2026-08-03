#include "flutter_window.h"

#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>
#include <optional>

#include "flutter/generated_plugin_registrant.h"
#include "native_bridge/audio_device_change_monitor.h"

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());
  ConfigureWindowAttentionChannel();
  ConfigureAudioDeviceChangeChannel();
  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  flutter_controller_->engine()->SetNextFrameCallback([&]() {
    this->Show();
  });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the first frame hasn't completed yet.
  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy() {
  if (audio_device_change_monitor_ != nullptr) {
    audio_device_change_monitor_->Stop();
    audio_device_change_monitor_->Release();
    audio_device_change_monitor_ = nullptr;
  }
  audio_device_change_channel_.reset();
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  if (message == kAudioDeviceChangedMessage) {
    NotifyAudioDevicesChanged();
    return 0;
  }

  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}

void FlutterWindow::ConfigureWindowAttentionChannel() {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          flutter_controller_->engine()->messenger(),
          "voip_desk/window_attention",
          &flutter::StandardMethodCodec::GetInstance());

  channel->SetMethodCallHandler(
      [this](const flutter::MethodCall<flutter::EncodableValue>& call,
             std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>>
                 result) {
        if (call.method_name() == "requestAttention") {
          RequestUserAttention();
          result->Success();
          return;
        }

        if (call.method_name() == "clearAttention") {
          ClearUserAttention();
          result->Success();
          return;
        }

        result->NotImplemented();
      });

  window_attention_channel_ = std::move(channel);
}

void FlutterWindow::ConfigureAudioDeviceChangeChannel() {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          flutter_controller_->engine()->messenger(),
          "voip_desk/audio_device_changes",
          &flutter::StandardMethodCodec::GetInstance());

  channel->SetMethodCallHandler(
      [this](const flutter::MethodCall<flutter::EncodableValue>& call,
             std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>>
                 result) {
        if (call.method_name() == "startMonitoring") {
          if (audio_device_change_monitor_ == nullptr) {
            audio_device_change_monitor_ = new AudioDeviceChangeMonitor();
          }
          const bool started =
              audio_device_change_monitor_->Start(GetHandle());
          result->Success(flutter::EncodableValue(started));
          return;
        }

        if (call.method_name() == "stopMonitoring") {
          if (audio_device_change_monitor_ != nullptr) {
            audio_device_change_monitor_->Stop();
          }
          result->Success();
          return;
        }

        result->NotImplemented();
      });

  audio_device_change_channel_ = std::move(channel);
}

void FlutterWindow::NotifyAudioDevicesChanged() {
  if (audio_device_change_channel_ == nullptr) {
    return;
  }
  audio_device_change_channel_->InvokeMethod(
      "audioDevicesChanged", std::make_unique<flutter::EncodableValue>());
}

void FlutterWindow::RequestUserAttention() {
  FLASHWINFO flash_info = {};
  flash_info.cbSize = sizeof(FLASHWINFO);
  flash_info.hwnd = GetHandle();
  flash_info.dwFlags = FLASHW_TRAY | FLASHW_TIMERNOFG;
  flash_info.uCount = 0;
  flash_info.dwTimeout = 0;
  ::FlashWindowEx(&flash_info);
}

void FlutterWindow::ClearUserAttention() {
  FLASHWINFO flash_info = {};
  flash_info.cbSize = sizeof(FLASHWINFO);
  flash_info.hwnd = GetHandle();
  flash_info.dwFlags = FLASHW_STOP;
  flash_info.uCount = 0;
  flash_info.dwTimeout = 0;
  ::FlashWindowEx(&flash_info);
}
