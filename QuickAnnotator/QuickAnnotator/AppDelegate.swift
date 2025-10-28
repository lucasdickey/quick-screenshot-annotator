import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    var mainViewController: MainViewController!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create main window
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.title = "Quick Annotator"
        window.setFrameAutosaveName("MainWindow")
        
        // Create and set main view controller
        mainViewController = MainViewController()
        window.contentViewController = mainViewController
        
        // Set up menu
        setupMenu()
        
        window.makeKeyAndOrderFront(nil)
        
        // Check clipboard on activation
        checkClipboardForImage()
    }
    
    func applicationDidBecomeActive(_ notification: Notification) {
        // Auto-paste if clipboard has image and no current image
        if mainViewController.canvasView.baseImage == nil {
            checkClipboardForImage()
        }
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    private func checkClipboardForImage() {
        if let image = ClipboardManager.shared.readImageFromClipboard() {
            mainViewController.loadImage(image)
        }
    }
    
    private func setupMenu() {
        let mainMenu = NSMenu()
        
        // App menu
        let appMenuItem = NSMenuItem()
        mainMenu.addItem(appMenuItem)
        let appMenu = NSMenu()
        appMenuItem.submenu = appMenu
        appMenu.addItem(withTitle: "About Quick Annotator", action: nil, keyEquivalent: "")
        appMenu.addItem(NSMenuItem.separator())
        appMenu.addItem(withTitle: "Quit Quick Annotator", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        
        // Edit menu
        let editMenuItem = NSMenuItem()
        mainMenu.addItem(editMenuItem)
        let editMenu = NSMenu(title: "Edit")
        editMenuItem.submenu = editMenu
        editMenu.addItem(withTitle: "Undo", action: #selector(MainViewController.undo), keyEquivalent: "z")
        editMenu.addItem(withTitle: "Redo", action: #selector(MainViewController.redo), keyEquivalent: "Z")
        editMenu.addItem(NSMenuItem.separator())
        editMenu.addItem(withTitle: "Paste", action: #selector(MainViewController.paste), keyEquivalent: "v")
        editMenu.addItem(withTitle: "Copy", action: #selector(MainViewController.copyToClipboard), keyEquivalent: "c")
        editMenu.addItem(NSMenuItem.separator())
        editMenu.addItem(withTitle: "Delete", action: #selector(MainViewController.deleteSelected), keyEquivalent: "\u{8}") // Backspace
        editMenu.addItem(withTitle: "Clear All", action: #selector(MainViewController.clearAll), keyEquivalent: "")
        
        NSApp.mainMenu = mainMenu
    }
}
