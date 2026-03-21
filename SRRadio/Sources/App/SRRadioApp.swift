import SwiftUI

@main
struct SRRadioApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            PlayerView()
                .background(VisualEffectView(material: .sidebar, blendingMode: .behindWindow))
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About SR Radio") {
                    NotificationCenter.default.post(name: NSNotification.Name("ShowAbout"), object: nil)
                }
            }
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        if let window = NSApplication.shared.windows.first {
            configureWindow(window)
        }
        setupMenu()
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    private func configureWindow(_ window: NSWindow) {
        window.setContentSize(NSSize(width: 320, height: 480))
        window.minSize = NSSize(width: 320, height: 480)
        window.maxSize = NSSize(width: 320, height: 480)
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.backgroundColor = .clear
        window.isOpaque = false
        window.styleMask.insert(.fullSizeContentView)
        window.center()
    }
    
    private func setupMenu() {
        let mainMenu = NSApplication.shared.mainMenu
        
        if let appMenuItem = mainMenu?.items.first {
            appMenuItem.submenu?.items = [
                NSMenuItem(title: "About SR Radio", action: #selector(showAbout), keyEquivalent: ""),
                NSMenuItem.separator(),
                NSMenuItem(title: "Hide SR Radio", action: #selector(NSApplication.hide(_:)), keyEquivalent: "h"),
                NSMenuItem(title: "Hide Others", action: #selector(NSApplication.hideOtherApplications(_:)), keyEquivalent: "h"),
                NSMenuItem.separator(),
                NSMenuItem(title: "Quit SR Radio", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
            ]
            if let aboutItem = appMenuItem.submenu?.items.first {
                aboutItem.target = self
            }
        }
        
        let fileMenuItem = NSMenuItem(title: "File", action: nil, keyEquivalent: "")
        let fileMenu = NSMenu(title: "File")
        fileMenu.addItem(NSMenuItem(title: "Close Window", action: #selector(NSWindow.performClose(_:)), keyEquivalent: "w"))
        fileMenuItem.submenu = fileMenu
        mainMenu?.addItem(fileMenuItem)
        
        let editMenuItem = NSMenuItem(title: "Edit", action: nil, keyEquivalent: "")
        let editMenu = NSMenu(title: "Edit")
        editMenu.addItem(NSMenuItem(title: "Undo", action: Selector(("undo:")), keyEquivalent: "z"))
        editMenu.addItem(NSMenuItem(title: "Redo", action: Selector(("redo:")), keyEquivalent: "Z"))
        editMenu.addItem(NSMenuItem.separator())
        editMenu.addItem(NSMenuItem(title: "Cut", action: #selector(NSText.cut(_:)), keyEquivalent: "x"))
        editMenu.addItem(NSMenuItem(title: "Copy", action: #selector(NSText.copy(_:)), keyEquivalent: "c"))
        editMenu.addItem(NSMenuItem(title: "Paste", action: #selector(NSText.paste(_:)), keyEquivalent: "v"))
        editMenu.addItem(NSMenuItem(title: "Select All", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a"))
        editMenuItem.submenu = editMenu
        mainMenu?.addItem(editMenuItem)
        
        let windowMenuItem = NSMenuItem(title: "Window", action: nil, keyEquivalent: "")
        let windowMenu = NSMenu(title: "Window")
        windowMenu.addItem(NSMenuItem(title: "Minimize", action: #selector(NSWindow.miniaturize(_:)), keyEquivalent: "m"))
        windowMenu.addItem(NSMenuItem.separator())
        windowMenu.addItem(NSMenuItem(title: "Close", action: #selector(NSWindow.performClose(_:)), keyEquivalent: "w"))
        windowMenuItem.submenu = windowMenu
        mainMenu?.addItem(windowMenuItem)
    }
    
    @objc private func showAbout() {
        NotificationCenter.default.post(name: NSNotification.Name("ShowAbout"), object: nil)
    }
}
