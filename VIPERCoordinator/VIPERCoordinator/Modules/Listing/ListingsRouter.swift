//
//  ListingRouter.swift
//  VIPERCoordinator
//
//  Created by Preet Singh on 3/01/26.
//


import Combine

/// Router protocol — emits navigation events for the Coordinator to handle.
protocol ListingRouterProtocol {
    var navigationPublisher: AnyPublisher<ListingNavigationEvent, Never> { get }
    func navigateToDetail(_ listing: Listing)
    func navigateToFilter()
}

final class ListingRouter: ListingRouterProtocol {
    private let navigationSubject = PassthroughSubject<ListingNavigationEvent, Never>()
    
    var navigationPublisher: AnyPublisher<ListingNavigationEvent, Never> {
        navigationSubject.eraseToAnyPublisher()
    }
    
    func navigateToDetail(_ listing: Listing) {
        navigationSubject.send(.showDetail(listing))
    }
    
    func navigateToFilter() {
        navigationSubject.send(.showFilter)
    }
}
