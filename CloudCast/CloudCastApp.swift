//
//  CloudCastApp.swift
//  CloudCast
//
//  Created by Sahil ChowKekar on 10/2/25.
//

import SwiftUI
import Amplify
import AWSCognitoAuthPlugin
import AWSS3StoragePlugin
import AWSAPIPlugin



@main
struct MyApp: App {
    @StateObject private var amplify = AmplifyService.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(amplify) 
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
