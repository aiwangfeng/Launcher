import AppKit
import Foundation

struct AppLauncher {
    static func launch(_ app: AppModel) {
        let configuration = NSWorkspace.OpenConfiguration()
        configuration.activates = true
        
        NSWorkspace.shared.openApplication(at: app.url, configuration: configuration) { _, error in
            if let error = error {
                print("Failed to launch app: \(error.localizedDescription)")
            }
        }
    }
}
