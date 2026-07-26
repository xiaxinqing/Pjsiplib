import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
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
