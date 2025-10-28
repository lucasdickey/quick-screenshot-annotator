import Cocoa

extension CanvasView {
    
    // MARK: - Select Mode Handlers
    
    func handleSelectModeMouseDown(at point: CGPoint) {
        // Check if clicking on a resize handle of selected circle
        if let circle = selectedAnnotation as? CircleAnnotation {
            let handles = circle.getResizeHandles()
            for (index, handle) in handles.enumerated() {
                if handle.contains(point) {
                    resizingCircle = circle
                    resizeHandleIndex = index
                    dragStartPoint = point
                    return
                }
            }
        }
        
        // Check if clicking on an annotation
        if let annotation = annotationManager.findAnnotation(at: point) {
            selectedAnnotation = annotation
            dragStartPoint = point
            isDragging = false
            needsDisplay = true
        } else {
            selectedAnnotation = nil
            dragStartPoint = nil
            needsDisplay = true
        }
    }
    
    func handleSelectModeMouseDragged(to point: CGPoint) {
        guard let startPoint = dragStartPoint else { return }
        
        // Handle circle resizing
        if let circle = resizingCircle, let _ = resizeHandleIndex {
            let newRadius = sqrt(pow(point.x - circle.center.x, 2) + pow(point.y - circle.center.y, 2))
            
            if !isDragging {
                annotationManager.updateAnnotations()
                isDragging = true
            }
            
            circle.resize(to: newRadius)
            needsDisplay = true
            return
        }
        
        // Handle moving annotation
        if let annotation = selectedAnnotation {
            let delta = CGPoint(x: point.x - startPoint.x, y: point.y - startPoint.y)
            
            if !isDragging {
                annotationManager.updateAnnotations()
                isDragging = true
            }
            
            annotation.move(by: delta)
            dragStartPoint = point
            needsDisplay = true
        }
    }
    
    func handleSelectModeMouseUp(at point: CGPoint) {
        resizingCircle = nil
        resizeHandleIndex = nil
        dragStartPoint = nil
        isDragging = false
    }
    
    // MARK: - Circle Mode Handlers
    
    func handleCircleModeMouseDown(at point: CGPoint) {
        tempCircleCenter = point
        tempCircleRadius = 0
    }
    
    func handleCircleModeMouseDragged(to point: CGPoint) {
        guard let center = tempCircleCenter else { return }
        
        // Calculate radius from center to current point
        tempCircleRadius = sqrt(pow(point.x - center.x, 2) + pow(point.y - center.y, 2))
        needsDisplay = true
    }
    
    func handleCircleModeMouseUp(at point: CGPoint) {
        guard let center = tempCircleCenter, tempCircleRadius > 5 else {
            // Too small, cancel
            tempCircleCenter = nil
            tempCircleRadius = 0
            needsDisplay = true
            return
        }
        
        // Create circle annotation
        let circle = CircleAnnotation(
            center: center,
            radius: tempCircleRadius,
            color: currentColor.nsColor
        )
        annotationManager.add(circle)
        
        // Reset temp state
        tempCircleCenter = nil
        tempCircleRadius = 0
        
        // Switch back to select mode
        currentMode = .select
        
        needsDisplay = true
    }
    
    // MARK: - Text Mode Handlers
    
    func handleTextModeMouseDown(at point: CGPoint) {
        createTextAnnotation(at: point)
    }
    
    // MARK: - Text Editing
    
    func createTextAnnotation(at point: CGPoint) {
        let textAnnotation = TextAnnotation(
            position: point,
            text: "",
            fontSize: 12,
            color: currentColor.nsColor
        )
        
        annotationManager.add(textAnnotation)
        startEditingText(textAnnotation)
        
        // Switch back to select mode
        currentMode = .select
    }
    
    func startEditingText(_ textAnnotation: TextAnnotation) {
        editingText = textAnnotation
        
        // Create text field for editing
        let textField = NSTextField(frame: NSRect(
            x: textAnnotation.position.x,
            y: textAnnotation.position.y,
            width: 200,
            height: 24
        ))
        
        textField.stringValue = textAnnotation.text
        textField.font = NSFont.systemFont(ofSize: textAnnotation.fontSize)
        textField.textColor = textAnnotation.color
        textField.backgroundColor = NSColor.white.withAlphaComponent(0.8)
        textField.isBordered = true
        textField.focusRingType = .default
        textField.delegate = self
        
        addSubview(textField)
        window?.makeFirstResponder(textField)
        
        self.textField = textField
    }
    
    func finishEditingText() {
        guard let textField = textField,
              let textAnnotation = editingText else { return }
        
        textAnnotation.text = textField.stringValue
        
        // Remove empty text annotations
        if textAnnotation.text.isEmpty {
            annotationManager.remove(textAnnotation)
        }
        
        textField.removeFromSuperview()
        self.textField = nil
        self.editingText = nil
        
        needsDisplay = true
    }
    
    // MARK: - Public Methods
    
    func deleteSelectedAnnotation() {
        guard let annotation = selectedAnnotation else { return }
        annotationManager.remove(annotation)
        selectedAnnotation = nil
        needsDisplay = true
    }
    
    func clearAllAnnotations() {
        annotationManager.clear()
        selectedAnnotation = nil
        needsDisplay = true
    }
    
    func undo() {
        if annotationManager.undo() {
            selectedAnnotation = nil
            needsDisplay = true
        }
    }
    
    func redo() {
        if annotationManager.redo() {
            selectedAnnotation = nil
            needsDisplay = true
        }
    }
    
    // Render to image
    func renderToImage() -> NSImage? {
        guard let image = baseImage else { return nil }
        
        let size = image.size
        let imageRect = NSRect(origin: .zero, size: size)
        
        let renderedImage = NSImage(size: size)
        renderedImage.lockFocus()
        
        // Draw base image
        image.draw(in: imageRect)
        
        // Draw annotations
        if let context = NSGraphicsContext.current?.cgContext {
            for annotation in annotationManager.annotations {
                annotation.draw(in: context)
            }
        }
        
        renderedImage.unlockFocus()
        
        return renderedImage
    }
}

// MARK: - NSTextFieldDelegate

extension CanvasView: NSTextFieldDelegate {
    func controlTextDidEndEditing(_ obj: Notification) {
        finishEditingText()
    }
}
