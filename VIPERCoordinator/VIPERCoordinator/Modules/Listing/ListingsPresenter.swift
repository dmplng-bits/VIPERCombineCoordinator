//
//  ListingPresenter.swift
//  VIPERCoordinator
//
//  Created by Preet Singh on 3/01/26.
//

import Foundation
import Combine

/// Presenter protocol — enables test injection.
protocol ListingPresenterProtocol: ObservableObject {
    var viewState: ListingViewState { get }
    var searchQuery: String { get set }
    func onAppear()
    func onTapListing(_ listing: Listing)
    func onTapFilter()
}

@MainActor
final class ListingPresenter: ListingPresenterProtocol {
    @Published var viewState: ListingViewState = .idle
    @Published var searchQuery: String = ""
    
    private let interactor: ListingInteractorProtocol
    private let router: ListingRouterProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(interactor: ListingInteractorProtocol,
         router: ListingRouterProtocol) {
        self.interactor = interactor
        self.router = router
        bindSearch()
    }
    
    // MARK: - View Actions
    
    func onAppear() {
        guard viewState == .idle else { return }
        loadListings()
    }
    
    func onTapListing(_ listing: Listing) {
        router.navigateToDetail(listing)
    }
    
    func onTapFilter() {
        router.navigateToFilter()
    }
    
    // MARK: - Private
    
    private func loadListings() {
        viewState = .loading
        
        Task { [weak self] in
            guard let self else { return }
            do {
                let listings = try await self.interactor.fetchListings()
                self.viewState = .loaded(listings)
            } catch {
                self.viewState = .error(error.localizedDescription)
            }
        }
    }
    
    /// Debounce search input and re-fetch filtered results via Combine.
    private func bindSearch() {
        $searchQuery
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                guard let self else { return }
                Task { [weak self] in
                    guard let self else { return }
                    do {
                        let results = try await self.interactor.searchListings(query: query)
                        self.viewState = .loaded(results)
                    } catch {
                        self.viewState = .error(error.localizedDescription)
                    }
                }
            }
            .store(in: &cancellables)
    }
}
