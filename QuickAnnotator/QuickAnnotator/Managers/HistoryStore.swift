import Foundation
import Cocoa

// Codable struct for storing annotation history
struct AnnotationSession: Codable {
    let id: UUID
    let timestamp: Date
    let imageWidth: CGFloat
    let imageHeight: CGFloat
    let annotationCount: Int
    
    // Future: Store actual annotation data for recreation
    // For now, just metadata
}

class HistoryStore {
    static let shared = HistoryStore()
    
    private let fileName = "annotation_history.json"
    private var sessions: [AnnotationSession] = []
    
    private init() {
        loadHistory()
    }
    
    // Get application support directory
    private func getHistoryFileURL() -> URL? {
        guard let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let appDirectory = appSupport.appendingPathComponent("QuickAnnotator", isDirectory: true)
        
        // Create directory if it doesn't exist
        if !FileManager.default.fileExists(atPath: appDirectory.path) {
            try? FileManager.default.createDirectory(at: appDirectory, withIntermediateDirectories: true)
        }
        
        return appDirectory.appendingPathComponent(fileName)
    }
    
    // Save current annotation session
    func saveSession(imageSize: CGSize, annotationCount: Int) {
        let session = AnnotationSession(
            id: UUID(),
            timestamp: Date(),
            imageWidth: imageSize.width,
            imageHeight: imageSize.height,
            annotationCount: annotationCount
        )
        
        sessions.append(session)
        
        // Keep only last 100 sessions
        if sessions.count > 100 {
            sessions.removeFirst(sessions.count - 100)
        }
        
        saveHistory()
    }
    
    // Load history from disk
    private func loadHistory() {
        guard let fileURL = getHistoryFileURL(),
              FileManager.default.fileExists(atPath: fileURL.path),
              let data = try? Data(contentsOf: fileURL) else {
            return
        }
        
        let decoder = JSONDecoder()
        sessions = (try? decoder.decode([AnnotationSession].self, from: data)) ?? []
    }
    
    // Save history to disk
    private func saveHistory() {
        guard let fileURL = getHistoryFileURL() else { return }
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        if let data = try? encoder.encode(sessions) {
            try? data.write(to: fileURL)
        }
    }
    
    // Get all sessions (for future UI)
    func getAllSessions() -> [AnnotationSession] {
        return sessions
    }
    
    // Clear history
    func clearHistory() {
        sessions.removeAll()
        saveHistory()
    }
}
