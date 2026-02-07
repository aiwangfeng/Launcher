import Foundation
import AppKit

class AppScanner {
    static let shared = AppScanner()
    
    private let appDirectories = [
        URL(fileURLWithPath: "/Applications"),
        URL(fileURLWithPath: "/System/Applications"),
        URL(fileURLWithPath: "/System/Applications/Utilities"),
        URL(fileURLWithPath: "/Users/\(NSUserName())/Applications")
    ]
    
    func scanApps() async -> [AppModel] {
        let directories = self.appDirectories // Capture locally
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                var apps: [AppModel] = []
                var seenPaths = Set<String>()
                let fileManager = FileManager.default
                let resourceKeys: [URLResourceKey] = [.isExecutableKey, .isApplicationKey]
                
                for dir in directories {
                    guard let enumerator = fileManager.enumerator(
                        at: dir,
                        includingPropertiesForKeys: resourceKeys,
                        options: [.skipsHiddenFiles, .skipsPackageDescendants],
                        errorHandler: nil
                    ) else { continue }
                    
                    for case let url as URL in enumerator {
                        if url.pathExtension == "app" {
                            // Skip symbolic links
                            let resourceValues = try? url.resourceValues(forKeys: [.isSymbolicLinkKey])
                            if resourceValues?.isSymbolicLink == true {
                                continue
                            }
                            
                            // Use resolved path for deduplication
                            let resolvedPath = url.resolvingSymlinksInPath().path
                            if seenPaths.contains(resolvedPath) { continue }
                            seenPaths.insert(resolvedPath)
                            
                            if let app = AppScanner.processApp(at: url) {
                                apps.append(app)
                            }
                        }
                    }
                }
                
                let sorted = apps.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
                continuation.resume(returning: sorted)
            }
        }
    }
    
    private static func processApp(at url: URL) -> AppModel? {
        let name = url.deletingPathExtension().lastPathComponent
        // Avoid some system internal apps that might not be useful launchers
        let icon = NSWorkspace.shared.icon(forFile: url.path)
        icon.size = NSSize(width: 64, height: 64) // Normalize icon size
        
        var category = "Other"
        if let bundle = Bundle(url: url),
           let categoryType = bundle.infoDictionary?["LSApplicationCategoryType"] as? String {
             let extracted = categoryType.components(separatedBy: ".").last?.capitalized ?? ""
             let cleaned = extracted.trimmingCharacters(in: .whitespacesAndNewlines)
             if !cleaned.isEmpty && cleaned != "Macos" {
                 category = cleaned
             } else if cleaned == "Macos" {
                 category = "System"
             }
        }
        
        return AppModel(name: name, url: url, icon: icon, category: category)
    }
}
