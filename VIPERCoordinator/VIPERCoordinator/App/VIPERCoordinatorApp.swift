//
//  VIPERCoordinatorApp.swift
//  VIPERCoordinator
//
//  Created by Preet Singh on 3/01/26.
//

import SwiftUI
import UIKit
import Combine

// MARK: - Coordinator Container

/// Holds the AppCoordinator and its UINavigationController for the app's lifetime.
final class AppState: ObservableObject {
    let coordinator: AppCoordinator

    init() {
        let navigationController = UINavigationController()
        coordinator = AppCoordinator(navigationController: navigationController)
        coordinator.start()
    }
}

// MARK: - UIKit Bridge

/// Embeds the coordinator's UINavigationController into SwiftUI's view hierarchy.
struct CoordinatorView: UIViewControllerRepresentable {
    let coordinator: AppCoordinator

    func makeUIViewController(context: Context) -> UINavigationController {
        coordinator.navigationController
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}

// MARK: - Entry Point

@main
struct VIPERCoordinatorApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            CoordinatorView(coordinator: appState.coordinator)
                .ignoresSafeArea()
        }
    }
}
