import Cocoa

class ClipboardManager {
    static let shared = ClipboardManager()
    
    private init() {}
    
    // Read image from clipboard
    func readImageFromClipboard() -> NSImage? {
        let pasteboard = NSPasteboard.general
        
        // Try to read image data
        if let imageData = pasteboard.data(forType: .png) ?? pasteboard.data(forType: .tiff) {
            return NSImage(data: imageData)
        }
        
        // Try to read directly as NSImage
        if let image = NSImage(pasteboard: pasteboard) {
            return image
        }
        
        return nil
    }
    
    // Write image to clipboard
    func writeImageToClipboard(_ image: NSImage) -> Bool {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        
        // Convert to PNG data
        guard let tiffData = image.tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffData),
              let pngData = bitmapImage.representation(using: .png, properties: [:]) else {
            return false
        }
        
        pasteboard.setData(pngData, forType: .png)
        return true
    }
    
    // Check if clipboard has image
    func hasImage() -> Bool {
        let pasteboard = NSPasteboard.general
        return pasteboard.canReadObject(forClasses: [NSImage.self], options: nil)
    }
}
