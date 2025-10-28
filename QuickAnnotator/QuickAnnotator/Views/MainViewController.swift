import Cocoa

class MainViewController: NSViewController {
    
    var canvasView: CanvasView!
    var scrollView: NSScrollView!
    var toolbar: ToolbarView!
    
    override func loadView() {
        // Create main container view
        let containerView = NSView(frame: NSRect(x: 0, y: 0, width: 800, height: 600))
        self.view = containerView
        
        // Create toolbar
        toolbar = ToolbarView(frame: NSRect(x: 0, y: containerView.bounds.height - 60, width: containerView.bounds.width, height: 60))
        toolbar.autoresizingMask = [.width, .minYMargin]
        toolbar.delegate = self
        containerView.addSubview(toolbar)
        
        // Create scroll view for canvas
        scrollView = NSScrollView(frame: NSRect(x: 0, y: 0, width: containerView.bounds.width, height: containerView.bounds.height - 60))
        scrollView.autoresizingMask = [.width, .height]
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = true
        scrollView.autohidesScrollers = true
        scrollView.backgroundColor = NSColor.windowBackgroundColor
        
        // Create canvas view
        canvasView = CanvasView(frame: NSRect(x: 0, y: 0, width: 800, height: 600))
        
        // Set up scroll view
        scrollView.documentView = canvasView
        containerView.addSubview(scrollView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up key event monitoring
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            return self?.handleKeyDown(event) ?? event
        }
    }
    
    // MARK: - Image Loading
    
    func loadImage(_ image: NSImage) {
        canvasView.loadImage(image)
        
        // Adjust scroll view content size
        if let imageSize = image.representations.first?.size {
            canvasView.setFrameSize(imageSize)
            scrollView.documentView = canvasView
        }
    }
    
    // MARK: - Actions
    
    @objc func paste() {
        if let image = ClipboardManager.shared.readImageFromClipboard() {
            loadImage(image)
        }
    }
    
    @objc func copyToClipboard() {
        guard let renderedImage = canvasView.renderToImage() else {
            let alert = NSAlert()
            alert.messageText = "No Image"
            alert.informativeText = "Please paste an image first."
            alert.alertStyle = .warning
            alert.runModal()
            return
        }
        
        // Save to history
        if let imageSize = canvasView.baseImage?.size {
            HistoryStore.shared.saveSession(
                imageSize: imageSize,
                annotationCount: canvasView.annotationManager.annotations.count
            )
        }
        
        // Copy to clipboard
        if ClipboardManager.shared.writeImageToClipboard(renderedImage) {
            // Close window after copying
            view.window?.close()
        } else {
            let alert = NSAlert()
            alert.messageText = "Copy Failed"
            alert.informativeText = "Failed to copy image to clipboard."
            alert.alertStyle = .warning
            alert.runModal()
        }
    }
    
    @objc func undo() {
        canvasView.undo()
    }
    
    @objc func redo() {
        canvasView.redo()
    }
    
    @objc func deleteSelected() {
        canvasView.deleteSelectedAnnotation()
    }
    
    @objc func clearAll() {
        let alert = NSAlert()
        alert.messageText = "Clear All Annotations"
        alert.informativeText = "Are you sure you want to remove all annotations? This cannot be undone."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Clear")
        alert.addButton(withTitle: "Cancel")
        
        if alert.runModal() == .alertFirstButtonReturn {
            canvasView.clearAllAnnotations()
        }
    }
    
    // MARK: - Keyboard Handling
    
    private func handleKeyDown(_ event: NSEvent) -> NSEvent? {
        // Don't intercept if editing text
        if canvasView.textField?.currentEditor() != nil {
            return event
        }
        
        let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        
        // CMD+V - Paste
        if flags.contains(.command) && event.charactersIgnoringModifiers == "v" {
            paste()
            return nil
        }
        
        // CMD+C - Copy
        if flags.contains(.command) && event.charactersIgnoringModifiers == "c" {
            copyToClipboard()
            return nil
        }
        
        // CMD+Z - Undo
        if flags.contains(.command) && !flags.contains(.shift) && event.charactersIgnoringModifiers == "z" {
            undo()
            return nil
        }
        
        // CMD+SHIFT+Z - Redo
        if flags.contains([.command, .shift]) && event.charactersIgnoringModifiers == "z" {
            redo()
            return nil
        }
        
        // CMD+CTRL+C - Circle mode
        if flags.contains([.command, .control]) && event.charactersIgnoringModifiers == "c" {
            toolbar.selectMode(.circle)
            return nil
        }
        
        // CMD+CTRL+T - Text mode
        if flags.contains([.command, .control]) && event.charactersIgnoringModifiers == "t" {
            toolbar.selectMode(.text)
            return nil
        }
        
        // Delete/Backspace - Delete selected
        if event.keyCode == 51 || event.keyCode == 117 {
            deleteSelected()
            return nil
        }
        
        // ESC - Deselect
        if event.keyCode == 53 {
            canvasView.selectedAnnotation = nil
            canvasView.currentMode = .select
            toolbar.selectMode(.select)
            canvasView.needsDisplay = true
            return nil
        }
        
        return event
    }
}

// MARK: - ToolbarDelegate

extension MainViewController: ToolbarDelegate {
    func toolbarDidSelectMode(_ mode: EditMode) {
        canvasView.currentMode = mode
    }
    
    func toolbarDidSelectColor(_ color: AnnotationColor) {
        canvasView.currentColor = color
    }
    
    func toolbarDidRequestCopy() {
        copyToClipboard()
    }
    
    func toolbarDidRequestClearAll() {
        clearAll()
    }
}
