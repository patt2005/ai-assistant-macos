import Foundation
import ScreenCaptureKit
import Cocoa

final class ScreenCaptureController {
    static let shared = ScreenCaptureController()
    
    private init() {}
    
    func openScreenRecordingSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture") {
            NSWorkspace.shared.open(url)
        }
    }
    
    @MainActor
    private func captureWithScreenCaptureKit() async -> NSImage? {
        do {
            let content = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: false)
            
            guard let display = content.displays.first else {
                print("No display found")
                return nil
            }
            
            let excludedApps = content.applications.filter { app in
                return app.bundleIdentifier == Bundle.main.bundleIdentifier
            }
            
            let filter = SCContentFilter(display: display, excludingApplications: excludedApps, exceptingWindows: [])
            
            let config = SCStreamConfiguration()
            config.width = display.width
            config.height = display.height
            config.showsCursor = true
            
            if #available(macOS 14.0, *) {
                if let screenshot = try? await SCScreenshotManager.captureImage(contentFilter: filter, configuration: config) {
                    return NSImage(cgImage: screenshot, size: NSSize(width: screenshot.width, height: screenshot.height))
                }
            } else {
                print("Mac version is lower than 14.0")
            }
        } catch {
            print("❌ Error capturing screenshot: \(error.localizedDescription)")
        }
        return nil
    }
    
    private func captureWithCGWindow() -> NSImage? {
        guard let cgImage = CGDisplayCreateImage(CGMainDisplayID()) else {
            print("❌ Failed to capture screen using CGDisplayCreateImage")
            return nil
        }
        return NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))
    }
    
    @MainActor
    func captureScreenshot() async -> NSImage? {
        if #available(macOS 14.0, *) {
            return await captureWithScreenCaptureKit()
        }
        return captureWithCGWindow()
    }
}
