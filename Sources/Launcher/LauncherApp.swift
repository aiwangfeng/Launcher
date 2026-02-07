import SwiftUI
import AppKit
import Carbon

@main
struct LauncherApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    var appState = AppState()
    var localEventMonitor: Any?
    var hotKeyRef: EventHotKeyRef?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Initialize Popover
        let popover = NSPopover()
        popover.contentSize = NSSize(width: 320, height: 400)
        popover.behavior = .transient
        
        let contentView = MenuBarView()
            .environmentObject(appState)
        
        popover.contentViewController = NSHostingController(rootView: contentView)
        self.popover = popover
        
        // Initialize Status Item
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = self.statusItem?.button {
            var iconLoaded = false
            if let path = Bundle.module.path(forResource: "128", ofType: "png"),
               let image = NSImage(contentsOfFile: path) {
                image.size = NSSize(width: 22, height: 22)
                image.isTemplate = true 
                button.image = image
                iconLoaded = true
            }
            
            if !iconLoaded {
                button.image = NSImage(systemSymbolName: "magnifyingglass", accessibilityDescription: "Launcher")
            }
            
            button.action = #selector(statusBarButtonClicked(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        
        
        // Setup local event monitor for Escape key
        localEventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.keyCode == 53 { // Escape key
                self?.closePopover()
                return nil
            }
            return event
        }
        
        // Register global hotkey using Carbon API: Ctrl+Alt+L
        registerHotKey()
    }
    
    // Static reference for Carbon callback - must be strong to prevent deallocation
    private static var sharedInstance: AppDelegate?
    
    func registerHotKey() {
        AppDelegate.sharedInstance = self
        
        // Install event handler
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        
        InstallEventHandler(
            GetApplicationEventTarget(),
            { (nextHandler, theEvent, userData) -> OSStatus in
                // Must dispatch to main thread for UI operations
                DispatchQueue.main.async {
                    Task { @MainActor in
                        AppDelegate.sharedInstance?.togglePopover(nil)
                    }
                }
                return noErr
            },
            1,
            &eventType,
            nil,
            nil
        )
        
        // Register the hotkey: Ctrl+Alt+L
        // L = keycode 37
        // Ctrl = controlKey (bit 12) = 0x1000
        // Alt/Option = optionKey (bit 11) = 0x0800
        let hotKeyID = EventHotKeyID(signature: OSType(0x4C4E4348), id: 1) // "LNCH"
        let modifiers: UInt32 = UInt32(controlKey | optionKey)
        let keyCode: UInt32 = 37 // L key
        
        let status = RegisterEventHotKey(
            keyCode,
            modifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
        
        if status != noErr {
            print("Failed to register hotkey: \(status)")
        } else {
            print("✅ Hotkey Ctrl+Alt+L registered successfully!")
        }
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        if let monitor = localEventMonitor {
            NSEvent.removeMonitor(monitor)
        }
        if let hotKey = hotKeyRef {
            UnregisterEventHotKey(hotKey)
        }
    }
    
    @objc func statusBarButtonClicked(_ sender: AnyObject?) {
        guard let event = NSApp.currentEvent else { return }
        
        if event.type == .rightMouseUp {
            // Show context menu on right-click
            let menu = NSMenu()
            menu.addItem(NSMenuItem(title: "Exit Launcher", action: #selector(exitApp), keyEquivalent: ""))
            self.statusItem?.menu = menu
            self.statusItem?.button?.performClick(nil)
            self.statusItem?.menu = nil  // Reset so left-click works again
        } else {
            // Left-click toggles popover
            togglePopover(sender)
        }
    }
    
    @objc func togglePopover(_ sender: AnyObject?) {
        if self.popover?.isShown == true {
            closePopover()
        } else {
            showPopover()
        }
    }
    
    @objc func exitApp() {
        NSApp.terminate(nil)
    }
    
    func showPopover() {
        if let button = self.statusItem?.button {
            self.popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            NSApp.activate(ignoringOtherApps: true)
            self.popover?.contentViewController?.view.window?.makeKey()
        }
    }
    
    func closePopover() {
        self.popover?.performClose(nil)
        appState.searchText = ""
    }
}
