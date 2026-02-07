import Foundation

class RecentAppsManager {
    static let shared = RecentAppsManager()
    private let key = "RecentApps"
    private let maxRecent = 4
    
    var recentAppURLs: [URL] {
        get {
            guard let strings = UserDefaults.standard.stringArray(forKey: key) else { return [] }
            var seen = Set<String>()
            // Deduplicate on read and filter out invalid entries
            return strings.compactMap { urlString -> URL? in
                guard let url = URL(string: urlString) else { return nil }
                let path = url.path
                if seen.contains(path) { return nil }
                seen.insert(path)
                return url
            }
        }
        set {
            let strings = newValue.map { $0.absoluteString }
            UserDefaults.standard.set(strings, forKey: key)
        }
    }
    
    func add(_ app: AppModel) {
        var recents = recentAppURLs
        // Remove if exists (by path) to move to top
        let appPath = app.url.path
        recents.removeAll { $0.path == appPath }
        recents.insert(app.url, at: 0)
        if recents.count > maxRecent {
            recents = Array(recents.prefix(maxRecent))
        }
        recentAppURLs = recents
    }
}
