import Cocoa

class CircleAnnotation: Annotation {
    let id: UUID
    var bounds: CGRect  // x, y, width, height of the oval
    var color: NSColor
    let strokeWidth: CGFloat = 3.5

    init(bounds: CGRect, color: NSColor) {
        self.id = UUID()
        self.bounds = bounds
        self.color = color
    }

    // Legacy init for backward compatibility (creates a circle)
    init(center: CGPoint, radius: CGFloat, color: NSColor) {
        self.id = UUID()
        self.bounds = CGRect(
            x: center.x - radius,
            y: center.y - radius,
            width: radius * 2,
            height: radius * 2
        )
        self.color = color
    }
    
    func draw(in context: CGContext) {
        context.saveGState()

        // Set stroke properties
        context.setStrokeColor(color.cgColor)
        context.setLineWidth(strokeWidth)

        // Draw oval using bounds
        context.strokeEllipse(in: bounds)

        context.restoreGState()
    }
    
    func contains(point: CGPoint) -> Bool {
        // Check if point is inside the oval bounds (with some tolerance)
        let tolerance = strokeWidth * 2
        let expandedBounds = bounds.insetBy(dx: -tolerance, dy: -tolerance)
        return expandedBounds.contains(point)
    }
    
    func move(by delta: CGPoint) {
        bounds.origin.x += delta.x
        bounds.origin.y += delta.y
    }

    func getBounds() -> CGRect {
        return bounds.insetBy(dx: -strokeWidth, dy: -strokeWidth)
    }
    
    // Resize methods for handles
    func resize(to newBounds: CGRect) {
        // Ensure minimum size
        let minSize: CGFloat = 10
        self.bounds = CGRect(
            x: newBounds.origin.x,
            y: newBounds.origin.y,
            width: max(minSize, newBounds.width),
            height: max(minSize, newBounds.height)
        )
    }

    func getResizeHandles() -> [CGRect] {
        let handleSize: CGFloat = 8
        let minX = bounds.minX
        let midX = bounds.midX
        let maxX = bounds.maxX
        let minY = bounds.minY
        let midY = bounds.midY
        let maxY = bounds.maxY

        let positions: [CGPoint] = [
            CGPoint(x: minX, y: minY), // Bottom-left
            CGPoint(x: midX, y: minY), // Bottom
            CGPoint(x: maxX, y: minY), // Bottom-right
            CGPoint(x: maxX, y: midY), // Right
            CGPoint(x: maxX, y: maxY), // Top-right
            CGPoint(x: midX, y: maxY), // Top
            CGPoint(x: minX, y: maxY), // Top-left
            CGPoint(x: minX, y: midY)  // Left
        ]

        return positions.map { point in
            CGRect(
                x: point.x - handleSize / 2,
                y: point.y - handleSize / 2,
                width: handleSize,
                height: handleSize
            )
        }
    }
}
