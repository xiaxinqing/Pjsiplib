import Cocoa
import Darwin
import FlutterMacOS

// 登录来源只在启动事件到达时读一次，之后 Flutter 再来问也不会丢。
enum AppLaunchOrigin {
  private static var launchedAtLogin: Bool?
  private static var waitingResults: [FlutterResult] = []

  static func capture() {
    let event = NSAppleEventManager.shared().currentAppleEvent
    let fromSystemLogin = event?.eventID == kAEOpenApplication
      && event?.paramDescriptor(forKeyword: keyAEPropData)?.enumCodeValue
        == keyAELaunchedAsLogInItem
    let hasStartupArgument = CommandLine.arguments.contains("--autostart")
    let value = fromSystemLogin || hasStartupArgument
    NSLog(
      "VPhone launch origin: systemLogin=%@ startupArgument=%@",
      fromSystemLogin ? "true" : "false",
      hasStartupArgument ? "true" : "false"
    )
    launchedAtLogin = value
    waitingResults.forEach { $0(value) }
    waitingResults.removeAll()
  }

  static func reply(_ result: @escaping FlutterResult) {
    if let value = launchedAtLogin {
      result(value)
    } else {
      // Flutter 有时会先跑到 main，稍等 AppKit 的启动事件，别提前误判。
      waitingResults.append(result)
    }
  }
}

final class DockMenuCommandBridge {
  static let shared = DockMenuCommandBridge()

  private var channel: FlutterMethodChannel?
  private var menuLabels: [String: String] = [
    "openApp": "打开 VPhone",
    "settings": "设置",
    "aboutApp": "关于 VPhone",
    "restartApp": "重启应用…",
    "exitApp": "退出 VPhone",
  ]
  var isConfigured: Bool { channel != nil }

  private init() {}

  func configure(binaryMessenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(
      name: "voip_desk/dock_menu",
      binaryMessenger: binaryMessenger
    )
    channel?.setMethodCallHandler { call, result in
      switch call.method {
      case "requestApplicationTermination":
        // Reply before entering AppKit's termination negotiation. AppDelegate
        // will immediately call Flutter back and await prepareToTerminate.
        result(nil)
        DispatchQueue.main.async {
          NSApp.terminate(nil)
        }
      case "applicationTerminationReady":
        // Flutter has completed PJSIP/database cleanup. This explicit signal
        // prevents AppKit from remaining indefinitely in terminateLater when
        // the result callback of the native-to-Flutter call is delayed/lost.
        result(nil)
        (NSApp.delegate as? AppDelegate)?
          .completeFlutterTerminationPreparation(source: "Flutter ready signal")
      case "updateMenuLabels":
        if let labels = call.arguments as? [String: String] {
          self.menuLabels.merge(labels) { _, updated in updated }
        }
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  func invoke(_ method: String, result: FlutterResult? = nil) {
    channel?.invokeMethod(method, arguments: nil, result: result)
  }

  func menuTitle(_ key: String) -> String {
    menuLabels[key] ?? ""
  }
}

@main
class AppDelegate: FlutterAppDelegate {
  override func applicationDidFinishLaunching(_ notification: Notification) {
    AppLaunchOrigin.capture()
    super.applicationDidFinishLaunching(notification)
  }

  private static let terminationPreparationTimeout: TimeInterval = 15
  private static let terminationCompletionGracePeriod: TimeInterval = 3

  private var isPreparingTermination = false
  private var isReadyToTerminate = false
  private var terminationApplication: NSApplication?
  private var preparationTimeoutTimer: Timer?
  private var completionFallbackTimer: Timer?

  override func applicationDockMenu(_ sender: NSApplication) -> NSMenu? {
    let menu = NSMenu()
    menu.addItem(dockMenuItem(
      title: DockMenuCommandBridge.shared.menuTitle("openApp"),
      action: #selector(showMainWindowFromDockMenu),
      keyEquivalent: ""
    ))
    menu.addItem(dockMenuItem(
      title: DockMenuCommandBridge.shared.menuTitle("settings"),
      action: #selector(openSettingsFromDockMenu),
      keyEquivalent: ""
    ))
    menu.addItem(dockMenuItem(
      title: DockMenuCommandBridge.shared.menuTitle("aboutApp"),
      action: #selector(openAboutFromDockMenu),
      keyEquivalent: ""
    ))
    menu.addItem(dockMenuItem(
      title: DockMenuCommandBridge.shared.menuTitle("restartApp"),
      action: #selector(restartApplicationFromDockMenu),
      keyEquivalent: ""
    ))
    menu.addItem(NSMenuItem.separator())
    menu.addItem(dockMenuItem(
      title: DockMenuCommandBridge.shared.menuTitle("exitApp"),
      action: #selector(terminateFromDockMenu),
      keyEquivalent: ""
    ))
    return menu
  }

  private func dockMenuItem(
    title: String,
    action: Selector,
    keyEquivalent: String
  ) -> NSMenuItem {
    let item = NSMenuItem(title: title, action: action, keyEquivalent: keyEquivalent)
    item.target = self
    return item
  }

  @objc private func showMainWindowFromDockMenu() {
    _ = applicationShouldHandleReopen(NSApp, hasVisibleWindows: true)
  }

  @objc private func openSettingsFromDockMenu() {
    showMainWindowFromDockMenu()
    DockMenuCommandBridge.shared.invoke("openSettings")
  }

  @objc private func openAboutFromDockMenu() {
    showMainWindowFromDockMenu()
    DockMenuCommandBridge.shared.invoke("openAbout")
  }

  @objc private func restartApplicationFromDockMenu() {
    showMainWindowFromDockMenu()
    DockMenuCommandBridge.shared.invoke("restartApplication")
  }

  @objc private func terminateFromDockMenu() {
    NSApp.terminate(self)
  }

  override func applicationShouldTerminate(
    _ sender: NSApplication
  ) -> NSApplication.TerminateReply {
    if isReadyToTerminate {
      return .terminateNow
    }
    if isPreparingTermination {
      return .terminateLater
    }
    guard DockMenuCommandBridge.shared.isConfigured else {
      return .terminateNow
    }

    isPreparingTermination = true
    terminationApplication = sender
    scheduleTerminationPreparationTimeout()
    NSLog("VPhone waiting for Flutter shutdown preparation.")
    DockMenuCommandBridge.shared.invoke("prepareToTerminate") {
      [weak self] _ in
      self?.completeFlutterTerminationPreparation(
        source: "Flutter method result"
      )
    }
    return .terminateLater
  }

  /// Completes AppKit's terminateLater negotiation exactly once.
  ///
  /// Both the explicit Flutter ready signal and the original method result
  /// callback enter here. Whichever arrives first wins; the other is ignored.
  func completeFlutterTerminationPreparation(source: String) {
    if !Thread.isMainThread {
      RunLoop.main.perform(inModes: [.common]) { [weak self] in
        self?.completeFlutterTerminationPreparation(source: source)
      }
      return
    }
    guard isPreparingTermination else {
      return
    }

    preparationTimeoutTimer?.invalidate()
    preparationTimeoutTimer = nil
    isPreparingTermination = false
    isReadyToTerminate = true

    let application = terminationApplication ?? NSApp
    terminationApplication = nil
    NSLog("VPhone Flutter shutdown preparation completed via %@.", source)
    application?.reply(toApplicationShouldTerminate: true)
    scheduleTerminationCompletionFallback()
  }

  /// Cancels a stuck preparation instead of keeping every later Quit request
  /// trapped in terminateLater. A later request can safely retry because the
  /// Flutter shutdown coordinator is idempotent.
  private func scheduleTerminationPreparationTimeout() {
    preparationTimeoutTimer?.invalidate()
    let timer = Timer(timeInterval: Self.terminationPreparationTimeout, repeats: false) {
      [weak self] _ in
      guard let self, self.isPreparingTermination else {
        return
      }

      let application = self.terminationApplication ?? NSApp
      self.isPreparingTermination = false
      self.isReadyToTerminate = false
      self.terminationApplication = nil
      self.preparationTimeoutTimer = nil
      NSLog("VPhone Flutter shutdown preparation timed out; cancelling this termination request.")
      application?.reply(toApplicationShouldTerminate: false)
    }
    preparationTimeoutTimer = timer
    RunLoop.main.add(timer, forMode: .common)
  }

  /// Cleanup is already complete at this point. If AppKit still leaves the
  /// process alive, terminate it as a final safeguard against a zombie app.
  private func scheduleTerminationCompletionFallback() {
    completionFallbackTimer?.invalidate()
    let timer = Timer(timeInterval: Self.terminationCompletionGracePeriod, repeats: false) {
      [weak self] _ in
      guard let self, self.isReadyToTerminate else {
        return
      }
      NSLog("VPhone AppKit termination did not finish; forcing clean process exit.")
      Darwin.exit(EXIT_SUCCESS)
    }
    completionFallbackTimer = timer
    RunLoop.main.add(timer, forMode: .common)
  }

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    // VPhone runs like a desktop softphone: closing the main window should keep
    // the app alive so incoming calls and the tray/menu-bar entry still work.
    NSLog("VPhone window closed; keeping app alive for tray/menu-bar.")
    return false
  }

  override func applicationShouldHandleReopen(
    _ sender: NSApplication,
    hasVisibleWindows flag: Bool
  ) -> Bool {
    // Dock reopen can report a stale visible-window state after the Flutter
    // window has been hidden more than once, so always ask existing windows to
    // come back instead of only doing it when `flag` is false.
    NSLog(
      "VPhone Dock reopen requested. hasVisibleWindows=%@ windowCount=%ld",
      flag ? "true" : "false",
      sender.windows.count
    )
    sender.unhide(self)
    for window in sender.windows {
      guard window.canBecomeKey else {
        continue
      }
      NSLog(
        "VPhone restoring window. visible=%@ miniaturized=%@ screen=%@",
        window.isVisible ? "true" : "false",
        window.isMiniaturized ? "true" : "false",
        window.screen?.localizedName ?? "unknown"
      )
      if window.isMiniaturized {
        window.deminiaturize(self)
      }
      window.makeKeyAndOrderFront(self)
      window.orderFrontRegardless()
    }
    NSRunningApplication.current.activate(options: [
      .activateAllWindows,
      .activateIgnoringOtherApps,
    ])
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}
