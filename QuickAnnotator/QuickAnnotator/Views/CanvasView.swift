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
    private var selectedAnnotation: Annotation?
    private var dragStartPoint: CGPoint?
    private var isDragging = false
    
    // Circle creation state
    private var tempCircleCenter: CGPoint?
    private var tempCircleRadius: CGFloat = 0
    
    // Resize state
    private var resizingCircle: CircleAnnotation?
    private var resizeHandleIndex: Int?
    
    // Text editing
    private var editingText: TextAnnotation?
    private var textField: NSTextField?
    
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
        
        // Resize view to fit image
        if let imageSize = image.representations.first?.size {
            setFrameSize(imageSize)
        }
        
        needsDisplay = true
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        guard let context = NSGraphicsContext.current?.cgContext else { return }
        
        // Draw background
        context.setFillColor(NSColor.white.cgColor)
        context.fill(bounds)
        
        // Draw base image
        if let image = baseImage {
            let imageRect = CGRect(origin: .zero, size: bounds.size)
            image.draw(in: imageRect)
        }
        
        // Draw all annotations
        for annotation in annotationManager.annotations {
            annotation.draw(in: context)
        }
        
        // Draw temporary circle while creating
        if let center = tempCircleCenter, tempCircleRadius > 0 {
            context.setStrokeColor(currentColor.cgColor)
            context.setLineWidth(3.5)
            let rect = CGRect(
                x: center.x - tempCircleRadius,
                y: center.y - tempCircleRadius,
                width: tempCircleRadius * 2,
                height: tempCircleRadius * 2
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
        
        // Single click handling based on mode
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
