
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
}
