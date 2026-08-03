import CoreAudio
import FlutterMacOS

/// 监听 CoreAudio 端点变化，并向 Dart 转发轻量事件。
///
/// 该类不会枚举设备，也不会直接调用 PJSIP。CoreAudio 触发回调时设备拓扑可能
/// 仍在变化，因此由 Dart 负责防抖，并在设备稳定后执行现有的 PJSIP 刷新流程。
final class AudioDeviceChangeMonitor {
    private static let channelName = "voip_desk/audio_device_changes"

    private let systemObject = AudioObjectID(kAudioObjectSystemObject)
    private let listenerQueue = DispatchQueue(
        label: "com.veserve.vphone.audio-device-changes"
    )
    private var channel: FlutterMethodChannel?
    private var registeredSelectors: [AudioObjectPropertySelector] = []

    private lazy var propertyListener: AudioObjectPropertyListenerBlock = {
        [weak self] _, _ in
        DispatchQueue.main.async {
            self?.channel?.invokeMethod("audioDevicesChanged", arguments: nil)
        }
    }

    func configure(binaryMessenger: FlutterBinaryMessenger) {
        let channel = FlutterMethodChannel(
            name: Self.channelName,
            binaryMessenger: binaryMessenger
        )
        channel.setMethodCallHandler { [weak self] call, result in
            guard let self = self else {
                result(false)
                return
            }

            switch call.method {
            case "startMonitoring":
                result(self.startMonitoring())
            case "stopMonitoring":
                self.stopMonitoring()
                result(nil)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
        self.channel = channel
    }

    /// 注册系统设备列表以及默认输入、输出设备属性监听。
    ///
    /// 重复启动不会重复注册监听。
    private func startMonitoring() -> Bool {
        if !registeredSelectors.isEmpty {
            return true
        }

        let selectors: [AudioObjectPropertySelector] = [
            kAudioHardwarePropertyDevices,
            kAudioHardwarePropertyDefaultInputDevice,
            kAudioHardwarePropertyDefaultOutputDevice,
            kAudioHardwarePropertyDefaultSystemOutputDevice,
        ]

        for selector in selectors {
            var address = propertyAddress(for: selector)
            let status = AudioObjectAddPropertyListenerBlock(
                systemObject,
                &address,
                listenerQueue,
                propertyListener
            )
            guard status == noErr else {
                NSLog(
                    "VPhone audio device listener registration failed. selector=%u status=%d",
                    selector,
                    status
                )
                stopMonitoring()
                return false
            }
            registeredSelectors.append(selector)
        }

        return true
    }

    /// 只移除由 `startMonitoring` 注册的属性监听。
    private func stopMonitoring() {
        for selector in registeredSelectors {
            var address = propertyAddress(for: selector)
            AudioObjectRemovePropertyListenerBlock(
                systemObject,
                &address,
                listenerQueue,
                propertyListener
            )
        }
        registeredSelectors.removeAll()
    }

    private func propertyAddress(
        for selector: AudioObjectPropertySelector
    ) -> AudioObjectPropertyAddress {
        AudioObjectPropertyAddress(
            mSelector: selector,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
    }

    deinit {
        stopMonitoring()
    }
}
