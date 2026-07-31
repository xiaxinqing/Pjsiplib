import Cocoa
import FlutterMacOS

final class DockMenuCommandBridge {
  static let shared = DockMenuCommandBridge()

  private var channel: FlutterMethodChannel?
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
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  func invoke(_ method: String, result: FlutterResult? = nil) {
    channel?.invokeMethod(method, arguments: nil, result: result)
  }
}

@main
class AppDelegate: FlutterAppDelegate {
  private var isPreparingTermination = false
  private var isReadyToTerminate = false

  override func applicationDockMenu(_ sender: NSApplication) -> NSMenu? {
    let menu = NSMenu()
    menu.addItem(dockMenuItem(
      title: "打开 VPhone",
      action: #selector(showMainWindowFromDockMenu),
      keyEquivalent: ""
    ))
    menu.addItem(dockMenuItem(
      title: "设置",
      action: #selector(openSettingsFromDockMenu),
      keyEquivalent: ""
    ))
    menu.addItem(dockMenuItem(
      title: "关于 VPhone",
      action: #selector(openAboutFromDockMenu),
      keyEquivalent: ""
    ))
    menu.addItem(dockMenuItem(
      title: "重启应用...",
      action: #selector(restartApplicationFromDockMenu),
      keyEquivalent: ""
    ))
    menu.addItem(NSMenuItem.separator())
    menu.addItem(dockMenuItem(
      title: "退出 VPhone",
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
    NSLog("VPhone waiting for Flutter shutdown preparation.")
    DockMenuCommandBridge.shared.invoke("prepareToTerminate") {
      [weak self] _ in
      DispatchQueue.main.async {
        guard let self, self.isPreparingTermination else {
          return
        }
        self.isPreparingTermination = false
        self.isReadyToTerminate = true
        NSLog("VPhone Flutter shutdown preparation completed.")
        sender.reply(toApplicationShouldTerminate: true)
      }
    }
    return .terminateLater
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
