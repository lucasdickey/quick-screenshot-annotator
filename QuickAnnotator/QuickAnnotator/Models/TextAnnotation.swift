import Cocoa

class TextAnnotation: Annotation {
    let id: UUID
    var position: CGPoint
    var text: String
    var fontSize: CGFloat
    var color: NSColor
    
    init(position: CGPoint, text: String = "", fontSize: CGFloat = 12, color: NSColor) {
        self.id = UUID()
        self.position = position
        self.text = text
        self.fontSize = fontSize
        self.color = color
    }
    
    func draw(in context: CGContext) {
        guard !text.isEmpty else { return }
        
        context.saveGState()
        
        // Flip context for text rendering
        context.textMatrix = .identity
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: fontSize),
            .foregroundColor: color
        ]
        
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        let line = CTLineCreateWithAttributedString(attributedString)
        
        // Draw text at position
        context.textPosition = position
        CTLineDraw(line, context)
        
        context.restoreGState()
    }
    
    func contains(point: CGPoint) -> Bool {
        let bounds = getBounds()
        return bounds.contains(point)
    }
    
    func move(by delta: CGPoint) {
        position = CGPoint(x: position.x + delta.x, y: position.y + delta.y)
    }
    
    func getBounds() -> CGRect {
        guard !text.isEmpty else {
            return CGRect(x: position.x, y: position.y, width: 100, height: fontSize + 4)
        }
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: fontSize)
        ]
        
        let size = (text as NSString).size(withAttributes: attributes)
        
        return CGRect(
            x: position.x - 2,
            y: position.y - 2,
            width: size.width + 4,
            height: size.height + 4
        )
    }
}
