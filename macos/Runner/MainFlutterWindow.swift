import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  private var attentionRequestID: Int = 0
  private var attentionTimer: Timer?
  private var attentionPulseCount: Int = 0
  private let maximumAttentionPulses: Int = 6

  override func awakeFromNib() {
    titleVisibility = .hidden
    titlebarAppearsTransparent = true
    styleMask.insert(.fullSizeContentView)
    isMovableByWindowBackground = true

    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)
    configureWindowAttentionChannel(flutterViewController: flutterViewController)

    super.awakeFromNib()
  }

  private func configureWindowAttentionChannel(flutterViewController: FlutterViewController) {
    let channel = FlutterMethodChannel(
      name: "voip_desk/window_attention",
      binaryMessenger: flutterViewController.engine.binaryMessenger
    )

    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else {
        result(nil)
        return
      }

      switch call.method {
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

  private func startAttentionPulses() {
    clearAttentionRequest()
    attentionPulseCount = 0
    pulseAttention()
    attentionTimer = Timer.scheduledTimer(withTimeInterval: 1.2, repeats: true) { [weak self] timer in
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
