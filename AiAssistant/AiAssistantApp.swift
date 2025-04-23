import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    static var shared: AppDelegate!
    
    var statusItem: NSStatusItem!
    var window: NSWindow?
    var loadingWindow: NSWindow?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        AppDelegate.shared = self
        
        Constants.shared.loadConfig()
        
        Task {
            do {
                try await UserApi.shared.getApiKey()
                try await UserApi.shared.fetchUserStatus()
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "bubble.left.and.bubble.right", accessibilityDescription: "Assistant")
            button.action = #selector(toggleOrRestoreWindow)
        }
        
        createWindow()
    }
    
    func createWindow() {
        let contentView = ContentView()
        let hostingController = NSHostingController(rootView: contentView)
        
        window = FocusableWindow(
            contentRect: NSRect(x: 0, y: 0, width: windowWidth, height: windowHeight),
            styleMask: [.titled, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        window?.titleVisibility = .hidden
        window?.titlebarAppearsTransparent = true
        window?.isOpaque = false
        window?.isMovableByWindowBackground = true
        window?.backgroundColor = .clear
        window?.hasShadow = true
        window?.center()
        window?.contentView = hostingController.view
        window?.isReleasedWhenClosed = false
        window?.level = .normal
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        
        NotificationCenter.default.addObserver(forName: NSWindow.willCloseNotification, object: window, queue: .main) { _ in
            self.window = nil
        }
    }
    
    func createOverlayWindow() {
        let overlayView = LoadingAnimationView()
        let controller = NSHostingController(rootView: overlayView)
        
        if let screen = NSScreen.main {
            let frame = screen.frame
            
            let overlayWindow = NSWindow(
                contentRect: frame,
                styleMask: [.borderless],
                backing: .buffered,
                defer: false
            )
            
            overlayWindow.isOpaque = false
            overlayWindow.hasShadow = false
            overlayWindow.backgroundColor = .clear
            overlayWindow.ignoresMouseEvents = true
            overlayWindow.level = .screenSaver
            overlayWindow.center()
            overlayWindow.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            overlayWindow.contentView = controller.view
            overlayWindow.makeKeyAndOrderFront(nil)
            
            self.loadingWindow = overlayWindow
        }
    }
    
    func showLoadingAnimation() {
        if loadingWindow == nil {
            createOverlayWindow()
        }
    }
    
    func hideLoadingAnimation() {
        guard let window = loadingWindow else { return }
        
        DispatchQueue.main.async {
            window.orderOut(nil)
            self.loadingWindow = nil
        }
    }
    
    @objc func toggleOrRestoreWindow() {
        if let win = window {
            win.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            win.center()
        } else {
            createWindow()
            bringAppToFront()
        }
    }
}

@main
struct AiAssistantApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
