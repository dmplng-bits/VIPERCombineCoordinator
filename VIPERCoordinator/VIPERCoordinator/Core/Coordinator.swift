//
//  Coordinator.swift
//  VIPERCoordinator
//
//  Created by Preet Singh on 3/01/26.
//

import UIKit
import Combine

/// Base protocol for all coordinators.
protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get }
    var childCoordinators: [Coordinator] { get set }
    func start()
}

extension Coordinator {
    func addChild(_ coordinator: Coordinator) {
        childCoordinators.append(coordinator)
    }
    
    func removeChild(_ coordinator: Coordinator) {
        childCoordinators.removeAll { $0 === coordinator }
    }
}

/// Navigation intent — modules emit these; coordinators consume them.
protocol NavigationEvent {}
