import AppKit

// macOS 10.15–12 用这个小程序启动主应用，13+ 则直接走系统登录项。
final class LoginHelperDelegate: NSObject, NSApplicationDelegate {
  func applicationDidFinishLaunching(_ notification: Notification) {
    guard let helperID = Bundle.main.bundleIdentifier else {
      NSApp.terminate(nil)
      return
    }
    let appID = helperID.replacingOccurrences(
      of: "-LaunchAtLoginHelper$", with: "", options: .regularExpression
    )
    guard NSRunningApplication.runningApplications(withBundleIdentifier: appID).isEmpty else {
      NSApp.terminate(nil)
      return
    }

    // Helper 位于 VPhone.app/Contents/Library/LoginItems 下，往上四层就是主应用。
    var appURL = Bundle.main.bundleURL
    for _ in 0..<4 { appURL.deleteLastPathComponent() }
    let configuration = NSWorkspace.OpenConfiguration()
    configuration.arguments = ["--autostart"]
    // 先别抢焦点，主应用读完用户设置后会自己决定要不要显示。
    configuration.activates = false
    NSWorkspace.shared.openApplication(at: appURL, configuration: configuration) { _, _ in
      DispatchQueue.main.async { NSApp.terminate(nil) }
    }
  }
}

let app = NSApplication.shared
let delegate = LoginHelperDelegate()
app.delegate = delegate
app.run()
