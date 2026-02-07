import SwiftUI
import AppKit

struct MenuBarView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Search Bar
            TextField("Search...", text: $appState.searchText)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(10)
                .background(Color(NSColor.controlBackgroundColor))
                .onSubmit {
                    if let first = appState.filteredApps.first {
                        appState.launch(first)
                    }
                }
            
            Divider()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    if !appState.searchText.isEmpty {
                        // Search Results
                        ForEach(appState.filteredApps) { app in
                            AppRow(app: app) { appState.launch(app) }
                        }
                    } else {
                        // Recent Apps
                        if !appState.recentApps.isEmpty {
                            SectionHeader(title: "Recent", isFirst: true)
                            ForEach(appState.recentApps) { app in
                                AppRow(app: app) { appState.launch(app) }
                            }
                        }
                        
                        // Categorized Apps
                        ForEach(Array(groupedApps.enumerated()), id: \.element.key) { index, item in
                            SectionHeader(title: item.key, isFirst: appState.recentApps.isEmpty && index == 0)
                            ForEach(item.value) { app in
                                AppRow(app: app) { appState.launch(app) }
                            }
                        }
                    }
                }
                .padding(.bottom, 4)
            }
        }
        .frame(width: 320, height: 400, alignment: .top)
        .clipped()
        .background(VisualEffectView())
    }
    
    var groupedApps: [(key: String, value: [AppModel])] {
        // Exclude apps that are already in the recent list
        let recentPaths = Set(appState.recentApps.map { $0.url.path })
        let nonRecentApps = appState.allApps.filter { !recentPaths.contains($0.url.path) }
        let grouped = Dictionary(grouping: nonRecentApps, by: { $0.category })
        // Filter out empty categories and sort
        return grouped
            .filter { !$0.key.trimmingCharacters(in: .whitespaces).isEmpty && !$0.value.isEmpty }
            .sorted { $0.key < $1.key }
    }
}

struct SectionHeader: View {
    let title: String
    var isFirst: Bool = false
    
    var body: some View {
        Text(title)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(.secondary)
            .padding(.horizontal, 12)
            .padding(.top, isFirst ? 4 : 10)
            .padding(.bottom, 2)
    }
}

struct AppRow: View {
    let app: AppModel
    let action: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(nsImage: app.icon)
                    .resizable()
                    .frame(width: 28, height: 28)
                Text(app.name)
                    .lineLimit(1)
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isHovered ? Color.accentColor.opacity(0.2) : Color.clear)
            .cornerRadius(6)
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            isHovered = hovering
        }
        .padding(.horizontal, 4)
    }
}

// Custom ScrollView that hides scrollers
struct ScrollViewWithHiddenScrollers<Content: View>: NSViewRepresentable {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = false  // Don't reserve space for scroller
        scrollView.hasHorizontalScroller = false
        scrollView.scrollerStyle = .overlay  // Use overlay style (no reserved space)
        scrollView.drawsBackground = false
        scrollView.backgroundColor = .clear
        scrollView.contentView.drawsBackground = false
        
        let hostingView = NSHostingView(rootView: content)
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.documentView = hostingView
        
        // Set up constraints to fill the entire scroll view
        if let documentView = scrollView.documentView {
            NSLayoutConstraint.activate([
                documentView.leadingAnchor.constraint(equalTo: scrollView.contentView.leadingAnchor),
                documentView.trailingAnchor.constraint(equalTo: scrollView.contentView.trailingAnchor),
                documentView.topAnchor.constraint(equalTo: scrollView.contentView.topAnchor)
            ])
        }
        
        return scrollView
    }
    
    func updateNSView(_ nsView: NSScrollView, context: Context) {
        if let hostingView = nsView.documentView as? NSHostingView<Content> {
            hostingView.rootView = content
        }
    }
}
