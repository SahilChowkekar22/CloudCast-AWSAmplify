//
//  CloudCastApp.swift
//  CloudCast
//
//  Created by Sahil ChowKekar on 10/2/25.
//

import AWSAPIPlugin
import AWSCognitoAuthPlugin
import AWSS3StoragePlugin
import Amplify
import SwiftUI

@main
struct MyApp: App {
    @StateObject private var amplify = AmplifyService.shared
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(amplify)
                .onChange(of: scenePhase) { newPhase in
                    if newPhase == .active {
                        resumePendingUploadIfNeeded()
                    }
                }
        }
    }

    private func resumePendingUploadIfNeeded() {
        if let (key, fileURL) = amplify.retrievePendingUpload() {
            print("Resuming upload for key: \(key)")
            Task {
                do {
                    let options = StorageUploadFileRequest.Options(
                        accessLevel: .guest
                    )
                    let uploadTask = Amplify.Storage.uploadFile(
                        key: key,
                        local: fileURL,
                        options: options
                    )
                    _ = try await uploadTask.value
                    amplify.clearPendingUpload()
                    print("Resumed upload completed for key: \(key)")
                } catch {
                    print("Resume failed: \(error)")
                }
            }
        }

        // Resume downloads
        if let (key, localURL) = amplify.retrievePendingDownload() {
            Task {
                print("Resuming download for key: \(key)")
                do {
                    let options = StorageDownloadFileRequest.Options(
                        accessLevel: .guest
                    )
                    let task = Amplify.Storage.downloadFile(
                        key: key,
                        local: localURL,
                        options: options
                    )
                    _ = try await task.value
                    amplify.clearPendingDownload()
                    print("Download resumed and completed")
                } catch {
                    print("Download resume failed: \(error)")
                }
            }
        }
    }

    init() {
        configureAmplify()
    }

    func configureAmplify() {
        do {
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.add(plugin: AWSS3StoragePlugin())
            //            try Amplify.add(plugin: AWSAPIPlugin())
            try Amplify.configure()
            print("Amplify configured successfully")
        } catch {
            print(" Failed to initialize Amplify: \(error)")
        }
    }
}
