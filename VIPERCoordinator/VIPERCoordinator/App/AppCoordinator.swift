//
//  AppCoordinator.swift
//  VIPERCoordinator
//
//  Created by Preet Singh on 3/01/26.
//



import Combine
import UIKit


/// Root coordinator that owns the window and manages child flows.
final class AppCoordinator: Coordinator {
    let navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        showListings()
    }
    
    // MARK: - Flows
    
    private func showListings() {
        let module = ListingAssembly.build()
        
        // Subscribe to navigation events from the Listing module's router
        module.router.navigationPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] event in
                switch event {
                case .showDetail(let listing):
                    self?.showListingDetail(listing)
                case .showFilter:
                    self?.showFilter()
                }
            }
            .store(in: &cancellables)
        
        navigationController.setViewControllers([module.viewController], animated: false)
    }
    
    private func showListingDetail(_ listing: Listing) {
        // In a real app: build a Detail VIPER module via DetailAssembly
        let placeholder = UIViewController()
        placeholder.view.backgroundColor = .systemBackground
        placeholder.title = listing.title
        navigationController.pushViewController(placeholder, animated: true)
    }
    
    private func showFilter() {
        // In a real app: present a Filter module modally
        let placeholder = UIViewController()
        placeholder.view.backgroundColor = .systemBackground
        placeholder.title = "Filters"
        let nav = UINavigationController(rootViewController: placeholder)
        navigationController.present(nav, animated: true)
    }
}
