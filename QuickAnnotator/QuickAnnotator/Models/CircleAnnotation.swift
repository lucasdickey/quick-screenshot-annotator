import Cocoa

class CircleAnnotation: Annotation {
    let id: UUID
    var center: CGPoint
    var radius: CGFloat
    var color: NSColor
    let strokeWidth: CGFloat = 3.5
    
    init(center: CGPoint, radius: CGFloat, color: NSColor) {
        self.id = UUID()
        self.center = center
        self.radius = radius
        self.color = color
    }
    
    func draw(in context: CGContext) {
        context.saveGState()
        
        // Set stroke properties
        context.setStrokeColor(color.cgColor)
        context.setLineWidth(strokeWidth)
        
        // Draw circle
        let rect = CGRect(
            x: center.x - radius,
            y: center.y - radius,
            width: radius * 2,
            height: radius * 2
        )
        context.strokeEllipse(in: rect)
        
        context.restoreGState()
    }
    
    func contains(point: CGPoint) -> Bool {
        let distance = sqrt(pow(point.x - center.x, 2) + pow(point.y - center.y, 2))
        // Check if point is near the circle outline (within stroke width tolerance)
        let tolerance = strokeWidth * 2
        return abs(distance - radius) <= tolerance
    }
    
    func move(by delta: CGPoint) {
        center = CGPoint(x: center.x + delta.x, y: center.y + delta.y)
    }
    
    func getBounds() -> CGRect {
        return CGRect(
            x: center.x - radius - strokeWidth,
            y: center.y - radius - strokeWidth,
            width: (radius + strokeWidth) * 2,
            height: (radius + strokeWidth) * 2
        )
    }
    
    // Resize methods for handles
    func resize(to newRadius: CGFloat) {
        self.radius = max(10, newRadius) // Minimum radius of 10
    }
    
    func getResizeHandles() -> [CGRect] {
        let handleSize: CGFloat = 8
        let positions: [CGPoint] = [
            CGPoint(x: center.x, y: center.y + radius), // Top
            CGPoint(x: center.x + radius, y: center.y), // Right
            CGPoint(x: center.x, y: center.y - radius), // Bottom
            CGPoint(x: center.x - radius, y: center.y), // Left
            CGPoint(x: center.x + radius * cos(.pi / 4), y: center.y + radius * sin(.pi / 4)), // Top-right
            CGPoint(x: center.x + radius * cos(3 * .pi / 4), y: center.y + radius * sin(3 * .pi / 4)), // Top-left
            CGPoint(x: center.x + radius * cos(5 * .pi / 4), y: center.y + radius * sin(5 * .pi / 4)), // Bottom-left
            CGPoint(x: center.x + radius * cos(7 * .pi / 4), y: center.y + radius * sin(7 * .pi / 4))  // Bottom-right
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
