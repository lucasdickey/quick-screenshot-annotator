import Cocoa

// Base protocol for all annotations
protocol Annotation: AnyObject {
    var id: UUID { get }
    var color: NSColor { get set }
    
    func draw(in context: CGContext)
    func contains(point: CGPoint) -> Bool
    func move(by delta: CGPoint)
    func getBounds() -> CGRect
}

// Enum for annotation types (for serialization)
enum AnnotationType: String, Codable {
    case circle
    case text
}

// Color preset enum
enum AnnotationColor: String, CaseIterable, Codable {
    case red
    case yellow
    case cyan
    
    var nsColor: NSColor {
        switch self {
        case .red:
            return NSColor(red: 1.0, green: 0.231, blue: 0.188, alpha: 1.0) // #FF3B30
        case .yellow:
            return NSColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0) // #FFCC00
        case .cyan:
            return NSColor(red: 0.0, green: 0.851, blue: 1.0, alpha: 1.0) // #00D9FF
        }
    }
    
    var cgColor: CGColor {
        return nsColor.cgColor
    }
}
