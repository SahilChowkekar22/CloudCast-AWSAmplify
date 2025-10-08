
import Foundation
import Combine

@MainActor
final class AmplifyService: ObservableObject {
    static let shared = AmplifyService()

    @Published private(set) var isConfigured: Bool = true
    @Published private(set) var configurationError: Error? = nil

    private init() {
        // Amplify is already configured in MyApp.swift
        print("AmplifyService initialized (Amplify already configured in MyApp)")
    }
    
    // Pending Upload Persistence

        func persistUploadInfo(key: String, fileURL: URL) {
            let info = ["key": key, "fileURL": fileURL.path]
            UserDefaults.standard.set(info, forKey: "pendingUpload")
            print("Saved pending upload for key: \(key)")
        }

        func retrievePendingUpload() -> (String, URL)? {
            guard let info = UserDefaults.standard.dictionary(forKey: "pendingUpload") as? [String: String],
                  let key = info["key"],
                  let path = info["fileURL"] else {
                return nil
            }
            let url = URL(fileURLWithPath: path)
            print("Retrieved pending upload for key: \(key)")
            return (key, url)
        }

        func clearPendingUpload() {
            UserDefaults.standard.removeObject(forKey: "pendingUpload")
            print("Cleared pending upload info")
        }
    
    // Pending Download Persistence
        func persistDownloadInfo(key: String, localFile: URL) {
            let info = ["key": key, "localFile": localFile.path]
            UserDefaults.standard.set(info, forKey: "pendingDownload")
            print("Saved pending download for key: \(key)")
        }

        func retrievePendingDownload() -> (String, URL)? {
            guard let info = UserDefaults.standard.dictionary(forKey: "pendingDownload") as? [String: String],
                  let key = info["key"],
                  let path = info["localFile"] else {
                return nil
            }
            return (key, URL(fileURLWithPath: path))
        }

        func clearPendingDownload() {
            UserDefaults.standard.removeObject(forKey: "pendingDownload")
            print("Cleared pending download info")
        }
}
