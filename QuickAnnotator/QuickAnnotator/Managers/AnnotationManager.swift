import Foundation

class AnnotationManager {
    private(set) var annotations: [Annotation] = []
    private var undoStack: [[Annotation]] = []
    private var redoStack: [[Annotation]] = []
    private let maxUndoLevels = 50
    
    // Add annotation
    func add(_ annotation: Annotation) {
        saveStateForUndo()
        annotations.append(annotation)
        redoStack.removeAll()
    }
    
    // Remove annotation
    func remove(_ annotation: Annotation) {
        saveStateForUndo()
        annotations.removeAll { $0.id == annotation.id }
        redoStack.removeAll()
    }
    
    // Update (for moves, resizes, edits)
    func updateAnnotations() {
        // This is called before making changes to annotations
        saveStateForUndo()
        redoStack.removeAll()
    }
    
    // Clear all annotations
    func clear() {
        saveStateForUndo()
        annotations.removeAll()
        redoStack.removeAll()
    }
    
    // Undo
    func undo() -> Bool {
        guard !undoStack.isEmpty else { return false }
        
        let currentState = annotations.map { $0 as Annotation }
        redoStack.append(deepCopy(currentState))
        
        let previousState = undoStack.removeLast()
        annotations = deepCopy(previousState)
        
        return true
    }
    
    // Redo
    func redo() -> Bool {
        guard !redoStack.isEmpty else { return false }
        
        let currentState = annotations.map { $0 as Annotation }
        undoStack.append(deepCopy(currentState))
        
        let nextState = redoStack.removeLast()
        annotations = deepCopy(nextState)
        
        return true
    }
    
    var canUndo: Bool {
        return !undoStack.isEmpty
    }
    
    var canRedo: Bool {
        return !redoStack.isEmpty
    }
    
    // Find annotation at point
    func findAnnotation(at point: CGPoint) -> Annotation? {
        // Search in reverse order to prioritize most recently added
        for annotation in annotations.reversed() {
            if annotation.contains(point: point) {
                return annotation
            }
        }
        return nil
    }
    
    // Private helper to save state
    private func saveStateForUndo() {
        let currentState = annotations.map { $0 as Annotation }
        undoStack.append(deepCopy(currentState))
        
        // Limit undo stack size
        if undoStack.count > maxUndoLevels {
            undoStack.removeFirst()
        }
    }
    
    // Deep copy annotations
    private func deepCopy(_ annotations: [Annotation]) -> [Annotation] {
        return annotations.compactMap { annotation -> Annotation? in
            if let circle = annotation as? CircleAnnotation {
                return CircleAnnotation(center: circle.center, radius: circle.radius, color: circle.color)
            } else if let text = annotation as? TextAnnotation {
                let copy = TextAnnotation(position: text.position, text: text.text, fontSize: text.fontSize, color: text.color)
                return copy
            }
            return nil
        }
    }
}
