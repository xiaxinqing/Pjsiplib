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
            case "getCurrentAudioRoute":
                // 首次注册可能发生在系统音频服务尚未稳定时；查询路由时顺便重试。
                _ = self.startMonitoring()
                result(self.currentAudioRoute())
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

    /// 返回当前系统默认输入和输出端点。
    ///
    /// PJSIP 在 VPIO 模式下不会可靠保留具体设备 ID，因此 UI 展示直接以
    /// CoreAudio 的系统路由为准，不从 PJSIP 枚举结果反推。
    private func currentAudioRoute() -> [String: Any] {
        var route: [String: Any] = [:]
        if let input = defaultEndpoint(
            selector: kAudioHardwarePropertyDefaultInputDevice
        ) {
            route["input"] = input
        }
        if let output = defaultEndpoint(
            selector: kAudioHardwarePropertyDefaultOutputDevice
        ) {
            route["output"] = output
        }
        return route
    }

    private func defaultEndpoint(
        selector: AudioObjectPropertySelector
    ) -> [String: String]? {
        var address = propertyAddress(for: selector)
        var deviceID = AudioDeviceID(kAudioObjectUnknown)
        var size = UInt32(MemoryLayout<AudioDeviceID>.size)
        let status = AudioObjectGetPropertyData(
            systemObject,
            &address,
            0,
            nil,
            &size,
            &deviceID
        )
        guard status == noErr, deviceID != kAudioObjectUnknown else {
            return nil
        }

        let uid = stringProperty(
            deviceID: deviceID,
            selector: kAudioDevicePropertyDeviceUID
        ) ?? String(deviceID)
        let name = stringProperty(
            deviceID: deviceID,
            selector: kAudioObjectPropertyName
        ) ?? uid
        return ["id": uid, "name": name]
    }

    private func stringProperty(
        deviceID: AudioDeviceID,
        selector: AudioObjectPropertySelector
    ) -> String? {
        var address = AudioObjectPropertyAddress(
            mSelector: selector,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        var value: Unmanaged<CFString>?
        var size = UInt32(MemoryLayout<Unmanaged<CFString>?>.size)
        let status = AudioObjectGetPropertyData(
            deviceID,
            &address,
            0,
            nil,
            &size,
            &value
        )
        guard status == noErr, let value else { return nil }
        let text = value.takeUnretainedValue() as String
        return text.isEmpty ? nil : text
    }

    deinit {
        stopMonitoring()
    }
}
