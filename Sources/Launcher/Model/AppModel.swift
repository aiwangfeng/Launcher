import Foundation
import AppKit

struct AppModel: Identifiable, Hashable {
    var id: String { url.path }  // Use path as stable identifier
    let name: String
    let url: URL
    let icon: NSImage
    let category: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(url.path)
    }
    
    static func == (lhs: AppModel, rhs: AppModel) -> Bool {
        lhs.url.path == rhs.url.path
    }
}
