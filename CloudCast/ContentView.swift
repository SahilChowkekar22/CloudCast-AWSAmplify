//
//  ContentView.swift
//  CloudCast
//
//  Created by Sahil ChowKekar on 10/2/25.
//


import SwiftUI
import Amplify
import UniformTypeIdentifiers

struct ContentView: View {
    @EnvironmentObject private var amplify: AmplifyService
    @State private var isUploading = false
    @State private var isDownloading = false
    @State private var message: String?
    @State private var showFileImporter = false
    @State private var selectedVideoURL: URL?
    @State private var lastUploadedKey: String?   // store last uploaded key for download

    var body: some View {
        Group {
            if let error = amplify.configurationError {
                VStack(spacing: 12) {
                    Text("Amplify configuration failed")
                        .font(.headline)
                    Text(error.localizedDescription)
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                }
                .padding()
            } else if !amplify.isConfigured {
                VStack(spacing: 12) {
                    ProgressView("Configuring Amplify…")
                    Text("Please wait a moment")
                        .foregroundColor(.secondary)
                        .font(.footnote)
                }
                .padding()
            } else {
                VStack(spacing: 20) {
                    if isUploading {
                        ProgressView("Uploading video...")
                    } else {
                        VStack(spacing: 15) {
                            Button("Select & Upload Video") {
                                showFileImporter = true
                            }
                            Button("Upload Bundled Video") {
                                if let bundledURL = Bundle.main.url(forResource: "SampleVideo",
                                                                    withExtension: "mp4") {
                                    uploadVideo(fileURL: bundledURL)
                                } else {
                                    message = "Bundled video not found"
                                }
                            }
                        }
                    }

                    // Download button (only shows if we have uploaded something)
                    if let key = lastUploadedKey {
                        if isDownloading {
                            ProgressView("Downloading video...")
                        } else {
                            Button("Download Last Uploaded Video") {
                                downloadVideo(withKey: key)
                            }
                        }
                    }

                    if let msg = message {
                        Text(msg)
                            .foregroundColor(msg.contains("✅") ? .green : .red)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                }
                .padding()
                .fileImporter(
                    isPresented: $showFileImporter,
                    allowedContentTypes: [.movie, .video],
                    allowsMultipleSelection: false
                ) { result in
                    switch result {
                    case .success(let urls):
                        if let pickedURL = urls.first {
                            selectedVideoURL = pickedURL
                            uploadVideo(fileURL: pickedURL)
                        }
                    case .failure(let error):
                        message = "Failed to pick file: \(error.localizedDescription)"
                    }
                }
            }
        }
    }

    // Upload Video
    func uploadVideo(fileURL: URL) {
        guard amplify.isConfigured else {
            message = "Amplify is not configured yet. Please wait."
            return
        }

        isUploading = true
        let key = "uploads/\(UUID().uuidString).mp4"
        lastUploadedKey = key

        // Save metadata for recovery
        amplify.persistUploadInfo(key: key, fileURL: fileURL)
        
        Task {
            do {
                // Start upload
                let options = StorageUploadFileRequest.Options(accessLevel: .guest)
                let uploadTask = Amplify.Storage.uploadFile(key: key, local: fileURL, options: options)

                // Observe progress
                for try await progress in await uploadTask.progress {
                    await MainActor.run {
                        message = String(format: "📤 Uploading... %.0f%%", progress.fractionCompleted * 100)
                    }
                }

                // Wait for completion
                let uploadedKey = try await uploadTask.value

                await MainActor.run {
                    isUploading = false
                    message = "Upload complete: \(uploadedKey)"
                }
                //Clear pending record
                amplify.clearPendingUpload()

            } catch {
                await MainActor.run {
                    isUploading = false
                    message = "Upload failed: \(error.localizedDescription)"
                }
            }
        }
    }

    //Download Video
    func downloadVideo(withKey key: String) {
        guard amplify.isConfigured else {
            message = "Amplify is not configured yet. Please wait."
            return
        }

        isDownloading = true
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let localFileURL = documentsURL.appendingPathComponent("downloaded_video.mp4")
        
        // Save pending download info
        amplify.persistDownloadInfo(key: key, localFile: localFileURL)

        Task {
            do {
                let options = StorageDownloadFileRequest.Options(accessLevel: .guest)
                let downloadTask = Amplify.Storage.downloadFile(key: key, local: localFileURL, options: options)
                
                

                // Track progress
                for try await progress in await downloadTask.progress {
                    await MainActor.run {
                        message = String(format: "Downloading... %.0f%%", progress.fractionCompleted * 100)
                    }
                }

                _ = try await downloadTask.value

                await MainActor.run {
                    isDownloading = false
                    message = "Downloaded to: \(localFileURL.lastPathComponent)"
                    print("Saved at: \(localFileURL.path)")
                }
                
                // Clear download metadata
                amplify.clearPendingDownload()

            } catch {
                await MainActor.run {
                    isDownloading = false
                    message = "Download failed: \(error.localizedDescription)"
                }
            }
        }
    }
}

#Preview {
    ContentView()
}

