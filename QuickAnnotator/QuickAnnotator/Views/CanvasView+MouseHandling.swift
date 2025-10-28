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

        // Handle oval resizing
        if let oval = resizingCircle, let handleIndex = resizeHandleIndex {
            if !isDragging {
                annotationManager.updateAnnotations()
                isDragging = true
            }

            // Calculate new bounds based on which handle is being dragged
            let originalBounds = oval.bounds
            var newBounds = originalBounds

            // Handles: 0=BL, 1=B, 2=BR, 3=R, 4=TR, 5=T, 6=TL, 7=L
            switch handleIndex {
            case 0: // Bottom-left
                newBounds.size.width = originalBounds.maxX - point.x
                newBounds.size.height = originalBounds.maxY - point.y
                newBounds.origin.x = point.x
                newBounds.origin.y = point.y
            case 1: // Bottom
                newBounds.size.height = originalBounds.maxY - point.y
                newBounds.origin.y = point.y
            case 2: // Bottom-right
                newBounds.size.width = point.x - originalBounds.minX
                newBounds.size.height = originalBounds.maxY - point.y
                newBounds.origin.y = point.y
            case 3: // Right
                newBounds.size.width = point.x - originalBounds.minX
            case 4: // Top-right
                newBounds.size.width = point.x - originalBounds.minX
                newBounds.size.height = point.y - originalBounds.minY
            case 5: // Top
                newBounds.size.height = point.y - originalBounds.minY
            case 6: // Top-left
                newBounds.size.width = originalBounds.maxX - point.x
                newBounds.size.height = point.y - originalBounds.minY
                newBounds.origin.x = point.x
            case 7: // Left
                newBounds.size.width = originalBounds.maxX - point.x
                newBounds.origin.x = point.x
            default:
                break
            }

            oval.resize(to: newBounds)
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
    
    // MARK: - Circle/Oval Mode Handlers

    func handleCircleModeMouseDown(at point: CGPoint) {
        tempOvalStart = point
        tempOvalEnd = point
    }

    func handleCircleModeMouseDragged(to point: CGPoint) {
        guard let _ = tempOvalStart else { return }

        tempOvalEnd = point
        needsDisplay = true
    }

    func handleCircleModeMouseUp(at point: CGPoint) {
        guard let start = tempOvalStart, let end = tempOvalEnd else {
            tempOvalStart = nil
            tempOvalEnd = nil
            needsDisplay = true
            return
        }

        // Calculate bounds from start and end points
        let bounds = CGRect(
            x: min(start.x, end.x),
            y: min(start.y, end.y),
            width: abs(end.x - start.x),
            height: abs(end.y - start.y)
        )

        // Only create if large enough
        guard bounds.width > 5 && bounds.height > 5 else {
            tempOvalStart = nil
            tempOvalEnd = nil
            needsDisplay = true
            return
        }

        // Create oval annotation
        let oval = CircleAnnotation(
            bounds: bounds,
            color: currentColor.nsColor
        )
        annotationManager.add(oval)

        // Reset temp state
        tempOvalStart = nil
        tempOvalEnd = nil

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
