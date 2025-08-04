import Foundation
import os

final class ErrorLogger {
    static let shared = ErrorLogger()
    
    private let fileManager = FileManager.default
    private let logFileName = "error_logs.txt"
    private var logFileURL: URL?
    
    private init() {
        setupLogFile()
    }
    
    private func setupLogFile() {
        do {
            let docsURL = try fileManager.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            logFileURL = docsURL.appendingPathComponent(logFileName)
        } catch {
            print("ErrorLogger: Failed to set up log file URL - \(error)")
        }
    }
    
    func log(_ error: Error, context: String? = nil, file: String = #file, line: Int = #line) {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let filename = (file as NSString).lastPathComponent
        let contextInfo = context != nil ? "Context: \(context!)" : ""
        let logEntry = "[\(timestamp)] [\(filename):\(line)] Error: \(error.localizedDescription) \(contextInfo)\n"
        
#if DEBUG
        print("🛑 Error Logged: \(logEntry)")
#else
        os_log("🛑 Error Logged: %@", type: .error, logEntry)
#endif
        
        writeToFile(logEntry)
        sendToRemote(error: error, context: context)
    }
    
    private func writeToFile(_ message: String) {
        guard let url = logFileURL else { return }
        
        if !fileManager.fileExists(atPath: url.path) {
            fileManager.createFile(atPath: url.path, contents: nil)
        }
        
        do {
            let handle = try FileHandle(forWritingTo: url)
            defer { handle.closeFile() }
            handle.seekToEndOfFile()
            if let data = message.data(using: .utf8) {
                handle.write(data)
            }
        } catch {
            print("ErrorLogger: Failed to write to log file - \(error)")
        }
    }
    
    private func sendToRemote(error: Error, context: String?) {
        // ⛔️ Optional: Integrate Firebase Crashlytics, Sentry, etc.
        // Example:
        // Crashlytics.crashlytics().record(error: error)
    }
    
    func retrieveLogs() -> String? {
        guard let url = logFileURL,
              let data = try? Data(contentsOf: url),
              let content = String(data: data, encoding: .utf8) else {
            return nil
        }
        return content
    }
    
    func clearLogs() {
        guard let url = logFileURL else { return }
        do {
            try "".write(to: url, atomically: true, encoding: .utf8)
        } catch {
            print("ErrorLogger: Failed to clear log file - \(error)")
        }
    }
}
