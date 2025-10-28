import Cocoa

enum EditMode {
    case select
    case circle
    case text
}

class CanvasView: NSView {
    var baseImage: NSImage?
    var annotationManager = AnnotationManager()
    var currentMode: EditMode = .select
    var currentColor: AnnotationColor = .red
    
    // Selection state
    var selectedAnnotation: Annotation?
    var dragStartPoint: CGPoint?
    var isDragging = false

    // Oval creation state
    var tempOvalStart: CGPoint?
    var tempOvalEnd: CGPoint?

    // Resize state
    var resizingCircle: CircleAnnotation?
    var resizeHandleIndex: Int?

    // Text editing
    var editingText: TextAnnotation?
    var textField: NSTextField?
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        wantsLayer = true
        layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
    }
    
    func loadImage(_ image: NSImage) {
        self.baseImage = image
        self.annotationManager = AnnotationManager()
        self.selectedAnnotation = nil

        // Keep canvas at full window size, image will be centered
        needsDisplay = true
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        guard let context = NSGraphicsContext.current?.cgContext else { return }
        
        // Draw background
        context.setFillColor(NSColor.white.cgColor)
        context.fill(bounds)
        
        // Draw base image centered in canvas
        if let image = baseImage {
            let imageSize = image.size
            let x = (bounds.width - imageSize.width) / 2
            let y = (bounds.height - imageSize.height) / 2
            let imageRect = CGRect(x: x, y: y, width: imageSize.width, height: imageSize.height)
            image.draw(in: imageRect)
        }
        
        // Draw all annotations
        for annotation in annotationManager.annotations {
            annotation.draw(in: context)
        }
        
        // Draw temporary oval while creating
        if let start = tempOvalStart, let end = tempOvalEnd {
            context.setStrokeColor(currentColor.cgColor)
            context.setLineWidth(3.5)
            let rect = CGRect(
                x: min(start.x, end.x),
                y: min(start.y, end.y),
                width: abs(end.x - start.x),
                height: abs(end.y - start.y)
            )
            context.strokeEllipse(in: rect)
        }
        
        // Draw selection handles for selected circle
        if let circle = selectedAnnotation as? CircleAnnotation {
            drawSelectionHandles(for: circle, in: context)
        }
        
        // Draw selection box for selected text
        if let text = selectedAnnotation as? TextAnnotation {
            drawSelectionBox(for: text, in: context)
        }
    }
    
    private func drawSelectionHandles(for circle: CircleAnnotation, in context: CGContext) {
        let handles = circle.getResizeHandles()
        
        context.setFillColor(NSColor.white.cgColor)
        context.setStrokeColor(NSColor.blue.cgColor)
        context.setLineWidth(1.5)
        
        for handle in handles {
            context.fillEllipse(in: handle)
            context.strokeEllipse(in: handle)
        }
    }
    
    private func drawSelectionBox(for text: TextAnnotation, in context: CGContext) {
        let bounds = text.getBounds()
        
        context.setStrokeColor(NSColor.blue.cgColor)
        context.setLineWidth(1.5)
        context.stroke(bounds)
    }
    
    // MARK: - Mouse Events
    
    override func mouseDown(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        
        // Handle double-click for text placement (any mode)
        if event.clickCount == 2 {
            // Check if double-clicking existing text to edit
            if let textAnnotation = annotationManager.findAnnotation(at: point) as? TextAnnotation {
                startEditingText(textAnnotation)
                return
            }
            
            // Create new text annotation
            createTextAnnotation(at: point)
            return
        }
        
        // Check if clicking on an existing annotation (always allow selection)
        if let annotation = annotationManager.findAnnotation(at: point) {
            handleSelectModeMouseDown(at: point)
            return
        }

        // Single click handling based on mode for creating new annotations
        switch currentMode {
        case .select:
            handleSelectModeMouseDown(at: point)
        case .circle:
            handleCircleModeMouseDown(at: point)
        case .text:
            handleTextModeMouseDown(at: point)
        }
    }
    
    override func mouseDragged(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        
        switch currentMode {
        case .select:
            handleSelectModeMouseDragged(to: point)
        case .circle:
            handleCircleModeMouseDragged(to: point)
        case .text:
            break // No dragging in text mode
        }
    }
    
    override func mouseUp(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        
        switch currentMode {
        case .select:
            handleSelectModeMouseUp(at: point)
        case .circle:
            handleCircleModeMouseUp(at: point)
        case .text:
            break
        }
    }
}
