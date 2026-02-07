import SwiftUI

@MainActor
class AppState: ObservableObject {
    @Published var allApps: [AppModel] = []
    @Published var filteredApps: [AppModel] = []
    @Published var recentApps: [AppModel] = []
    @Published var searchText: String = "" {
        didSet {
            debounceSearch()
        }
    }
    
    private var searchDebounceTask: Task<Void, Never>?
    
    init() {
        Task {
            let apps = await AppScanner.shared.scanApps()
            self.allApps = apps
            self.filterApps()
            self.updateRecentApps()
        }
    }
    
    private func debounceSearch() {
        searchDebounceTask?.cancel()
        searchDebounceTask = Task {
            try? await Task.sleep(nanoseconds: 100_000_000) // 100ms debounce
            if !Task.isCancelled {
                filterApps()
            }
        }
    }
    
    func filterApps() {
        if searchText.isEmpty {
            filteredApps = allApps
        } else {
            // Score each app and sort by score (highest first)
            filteredApps = allApps
                .compactMap { app -> (app: AppModel, score: Int)? in
                    guard let score = FuzzyMatcher.score(query: searchText, target: app.name) else {
                        return nil
                    }
                    return (app, score)
                }
                .sorted { $0.score > $1.score }
                .map { $0.app }
        }
    }

    func launch(_ app: AppModel) {
        AppLauncher.launch(app)
        RecentAppsManager.shared.add(app)
        updateRecentApps()
        // Reset search
        searchText = ""
    }
    
    private func updateRecentApps() {
        let urls = RecentAppsManager.shared.recentAppURLs
        var seen = Set<String>()
        recentApps = urls.compactMap { url -> AppModel? in
            let path = url.path
            // Prevent duplicates
            guard !seen.contains(path) else { return nil }
            seen.insert(path)
            // Match by path, not URL object
            return allApps.first { $0.url.path == path }
        }
    }
}
