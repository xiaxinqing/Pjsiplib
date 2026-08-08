import Cocoa
import FlutterMacOS
import AVFoundation

class MainFlutterWindow: NSWindow {
    private let audioDeviceChangeMonitor = AudioDeviceChangeMonitor()
    private var attentionRequestID: Int = 0
    private var attentionTimer: Timer?
    private var attentionPulseCount: Int = 0
    private let maximumAttentionPulses: Int = 6
    private var launchSplashView: NSView?
    private var launchSplashFallbackTimer: Timer?
    private let launchBackgroundColor = NSColor(
        calibratedRed: 250.0 / 255.0,
        green: 250.0 / 255.0,
        blue: 250.0 / 255.0,
        alpha: 1.0
    )

    override func awakeFromNib() {
        backgroundColor = launchBackgroundColor
        titleVisibility = .hidden
        titlebarAppearsTransparent = true
        styleMask.insert(.fullSizeContentView)
        isMovableByWindowBackground = true

        let flutterViewController = FlutterViewController()
        flutterViewController.backgroundColor = launchBackgroundColor
        let windowFrame = self.frame
        self.contentViewController = flutterViewController
        flutterViewController.view.wantsLayer = true
        flutterViewController.view.layer?.backgroundColor = launchBackgroundColor.cgColor
        installLaunchSplash(on: flutterViewController.view)
        self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)
    DockMenuCommandBridge.shared.configure(
      binaryMessenger: flutterViewController.engine.binaryMessenger
    )
    configureLaunchSplashChannel(flutterViewController: flutterViewController)
        configureWindowAttentionChannel(flutterViewController: flutterViewController)
        configureAudioPermissionChannel(flutterViewController: flutterViewController)
        audioDeviceChangeMonitor.configure(
            binaryMessenger: flutterViewController.engine.binaryMessenger
        )

        super.awakeFromNib()
    }

    private func installLaunchSplash(on parentView: NSView) {
        let splashView = NSView(frame: parentView.bounds)
        splashView.autoresizingMask = [.width, .height]
        splashView.wantsLayer = true
        splashView.layer?.backgroundColor = launchBackgroundColor.cgColor

        let imageView = NSImageView()
        imageView.image = NSImage(named: "AppIcon") ?? NSApp.applicationIconImage
        imageView.imageScaling = .scaleProportionallyUpOrDown
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.wantsLayer = true
        imageView.layer?.shadowColor = NSColor.black.cgColor
        imageView.layer?.shadowOpacity = 0.08
        imageView.layer?.shadowRadius = 14
        imageView.layer?.shadowOffset = CGSize(width: 0, height: 8)

        let titleLabel = NSTextField(labelWithString: "VPhone")
        titleLabel.font = NSFont.systemFont(ofSize: 22, weight: .semibold)
        titleLabel.textColor = NSColor(
            calibratedRed: 24.0 / 255.0,
            green: 24.0 / 255.0,
            blue: 24.0 / 255.0,
            alpha: 1.0
        )
        titleLabel.alignment = .center

        let subtitleLabel = NSTextField(labelWithString: "loading…")
        subtitleLabel.font = NSFont.systemFont(ofSize: 13, weight: .regular)
        subtitleLabel.textColor = NSColor(
            calibratedRed: 105.0 / 255.0,
            green: 105.0 / 255.0,
            blue: 105.0 / 255.0,
            alpha: 1.0
        )
        subtitleLabel.alignment = .center

        let textStackView = NSStackView(views: [titleLabel, subtitleLabel])
        textStackView.orientation = .vertical
        textStackView.alignment = .centerX
        textStackView.spacing = 6
        textStackView.translatesAutoresizingMaskIntoConstraints = false

        let stackView = NSStackView(views: [imageView, textStackView])
        stackView.orientation = .vertical
        stackView.alignment = .centerX
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false

        splashView.addSubview(stackView)
        parentView.addSubview(splashView)

        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 92),
            imageView.heightAnchor.constraint(equalToConstant: 92),
            stackView.centerXAnchor.constraint(equalTo: splashView.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: splashView.centerYAnchor, constant: -18),
        ])

        launchSplashView = splashView
        launchSplashFallbackTimer?.invalidate()
        // Native-side safety net: the Dart side normally hides the placeholder
        // after the first Flutter frame. If that message never arrives, do not
        // leave the user permanently blocked on the startup screen.
        launchSplashFallbackTimer = Timer.scheduledTimer(withTimeInterval: 8.0, repeats: false) {
            [weak self] _ in
            NSLog("VPhone launch splash fallback hide fired.")
            self?.hideLaunchSplash()
        }
    }

    private func configureLaunchSplashChannel(flutterViewController: FlutterViewController) {
        let channel = FlutterMethodChannel(
            name: "voip_desk/launch_splash",
            binaryMessenger: flutterViewController.engine.binaryMessenger
        )

        channel.setMethodCallHandler {
            [weak self] call, result in
            switch call.method {
            case "hide":
                self?.hideLaunchSplash()
                result(nil)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    private func hideLaunchSplash() {
        launchSplashFallbackTimer?.invalidate()
        launchSplashFallbackTimer = nil

        guard let splashView = launchSplashView else {
            return
        }
        launchSplashView = nil

        NSAnimationContext.runAnimationGroup {
            context in
            context.duration = 0.16
            splashView.animator().alphaValue = 0
        } completionHandler: {
            splashView.removeFromSuperview()
        }
    }

    private func configureWindowAttentionChannel(flutterViewController: FlutterViewController) {
        let channel = FlutterMethodChannel(
            name: "voip_desk/window_attention",
            binaryMessenger: flutterViewController.engine.binaryMessenger
        )

        channel.setMethodCallHandler {
            [weak self] call, result in
            guard let self = self else {
                result(nil)
                return
            }

            switch call.method {
            case "presentIncomingCallWindow":
                self.presentIncomingCallWindow()
                result(nil)
            case "requestAttention":
                self.startAttentionPulses()
                result(nil)
            case "clearAttention":
                self.clearAttentionRequest()
                result(nil)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    /// Presents an incoming call on the Space the user is currently viewing.
    ///
    /// `makeKeyAndOrderFront` and Flutter's `windowManager.focus()` only raise
    /// a window inside its existing macOS Space. When VPhone is already active
    /// on another Space, those calls do not bring the call UI to the user. We
    /// temporarily opt into `moveToActiveSpace`, present the existing main
    /// window, then restore its previous collection behavior so normal window
    /// navigation is unchanged after the incoming-call transition.
    private func presentIncomingCallWindow() {
        let previousCollectionBehavior = collectionBehavior
        var incomingCallBehavior = previousCollectionBehavior
        // AppKit does not allow these two Space behaviors at the same time.
        incomingCallBehavior.remove(.canJoinAllSpaces)
        incomingCallBehavior.insert(.moveToActiveSpace)
        collectionBehavior = incomingCallBehavior

        NSApp.unhide(self)
        if isMiniaturized {
            deminiaturize(self)
        }
        makeKeyAndOrderFront(self)
        orderFrontRegardless()
        NSRunningApplication.current.activate(options: [
            .activateAllWindows,
            .activateIgnoringOtherApps,
        ])

        // Keep moveToActiveSpace only for this presentation. Restoring it on
        // the next run-loop turn avoids changing the user's later Space rules.
        DispatchQueue.main.async { [weak self] in
            self?.collectionBehavior = previousCollectionBehavior
        }
    }

    private func configureAudioPermissionChannel(flutterViewController: FlutterViewController) {
        let channel = FlutterMethodChannel(
            name: "voip_desk/audio_permission",
            binaryMessenger: flutterViewController.engine.binaryMessenger
        )

        channel.setMethodCallHandler {
            [weak self] call, result in
            guard let self = self else {
                result(nil)
                return
            }

            switch call.method {
            case "microphoneAuthorizationStatus":
                // Only report the current macOS privacy state. This check cannot
                // disturb active calls.
                result(self.microphoneAuthorizationStatusText())
            case "requestMicrophoneAccess":
                AVCaptureDevice.requestAccess(for: .audio) {
                    _ in
                    DispatchQueue.main.async {
                        result(self.microphoneAuthorizationStatusText())
                    }
                }
            case "openMicrophonePrivacySettings":
                if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Microphone") {
                    NSWorkspace.shared.open(url)
                }
                result(nil)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    private func microphoneAuthorizationStatusText() -> String {
        let status = AVCaptureDevice.authorizationStatus(for: .audio)
        switch status {
        case .authorized:
            return "authorized"
        case .denied:
            return "denied"
        case .restricted:
            return "restricted"
        case .notDetermined:
            return "notDetermined"
        @unknown default:
            return "unknown"
        }
    }

    private func startAttentionPulses() {
        clearAttentionRequest()
        attentionPulseCount = 0
        pulseAttention()
        attentionTimer = Timer.scheduledTimer(withTimeInterval: 1.2, repeats: true) {
            [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            guard self.attentionPulseCount < self.maximumAttentionPulses else {
                timer.invalidate()
                self.attentionTimer = nil
                return
            }
            self.pulseAttention()
        }
    }

    private func pulseAttention() {
        if attentionRequestID != 0 {
            NSApp.cancelUserAttentionRequest(attentionRequestID)
        }
        attentionRequestID = NSApp.requestUserAttention(.criticalRequest)
        attentionPulseCount += 1
    }

    private func clearAttentionRequest() {
        attentionTimer?.invalidate()
        attentionTimer = nil
        attentionPulseCount = 0
        if attentionRequestID != 0 {
            NSApp.cancelUserAttentionRequest(attentionRequestID)
            attentionRequestID = 0
        }
    }
}
