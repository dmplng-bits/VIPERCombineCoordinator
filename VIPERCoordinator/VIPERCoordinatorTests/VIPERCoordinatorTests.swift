//
//  VIPERCoordinatorTests.swift
//  VIPERCoordinatorTests
//
//  Created by Preet Singh on 3/01/26.
//

import XCTest
import Combine
import Foundation
@testable import VIPERCoordinator

// MARK: - Mocks

final class MockListingInteractor: ListingInteractorProtocol, @unchecked Sendable {
    var mockListings: [Listing] = [.preview]
    var shouldFail = false

    func fetchListings() async throws -> [Listing] {
        if shouldFail { throw URLError(.badServerResponse) }
        return mockListings
    }

    func searchListings(query: String) async throws -> [Listing] {
        let all = try await fetchListings()
        guard !query.isEmpty else { return all }
        return all.filter { $0.title.lowercased().contains(query.lowercased()) }
    }
}

final class MockListingRouter: ListingRouterProtocol {
    private let subject = PassthroughSubject<ListingNavigationEvent, Never>()
    var navigationPublisher: AnyPublisher<ListingNavigationEvent, Never> {
        subject.eraseToAnyPublisher()
    }

    var lastNavigationEvent: ListingNavigationEvent?

    func navigateToDetail(_ listing: Listing) {
        lastNavigationEvent = .showDetail(listing)
        subject.send(.showDetail(listing))
    }

    func navigateToFilter() {
        lastNavigationEvent = .showFilter
        subject.send(.showFilter)
    }
}

// MARK: - Presenter Tests

@MainActor
final class ListingPresenterTests: XCTestCase {
    var presenter: ListingPresenter!
    var interactor: MockListingInteractor!
    var router: MockListingRouter!

    override func setUp() {
        interactor = MockListingInteractor()
        router = MockListingRouter()
        presenter = ListingPresenter(interactor: interactor, router: router)
    }

    func testOnAppearLoadsListings() async throws {
        // Given
        XCTAssertEqual(presenter.viewState, .idle)

        // When
        presenter.onAppear()

        // Then — wait for async load
        try await Task.sleep(for: .seconds(1))
        if case .loaded(let listings) = presenter.viewState {
            XCTAssertEqual(listings.count, 1)
            XCTAssertEqual(listings.first?.title, Listing.preview.title)
        } else {
            XCTFail("Expected .loaded state, got \(presenter.viewState)")
        }
    }

    func testOnAppearShowsErrorOnFailure() async throws {
        // Given
        interactor.shouldFail = true

        // When
        presenter.onAppear()

        // Then
        try await Task.sleep(for: .seconds(1))
        if case .error = presenter.viewState {
            // Pass
        } else {
            XCTFail("Expected .error state, got \(presenter.viewState)")
        }
    }

    func testTapListingTriggersNavigation() {
        // When
        presenter.onTapListing(.preview)

        // Then
        if case .showDetail(let listing) = router.lastNavigationEvent {
            XCTAssertEqual(listing.id, Listing.preview.id)
        } else {
            XCTFail("Expected .showDetail event")
        }
    }

    func testTapFilterTriggersNavigation() {
        // When
        presenter.onTapFilter()

        // Then
        if case .showFilter = router.lastNavigationEvent {
            // Pass
        } else {
            XCTFail("Expected .showFilter event")
        }
    }
}

// MARK: - Interactor Tests

final class ListingInteractorTests: XCTestCase {

    func testFetchReturnsListings() async throws {
        let interactor = ListingInteractor()
        let listings = try await interactor.fetchListings()
        XCTAssertFalse(listings.isEmpty)
    }

    func testSearchFiltersResults() async throws {
        let interactor = ListingInteractor()
        let results = try await interactor.searchListings(query: "studio")
        XCTAssertTrue(results.allSatisfy {
            $0.title.lowercased().contains("studio") ||
            $0.subtitle.lowercased().contains("studio")
        })
    }

    func testEmptySearchReturnsAll() async throws {
        let interactor = ListingInteractor()
        let all = try await interactor.fetchListings()
        let results = try await interactor.searchListings(query: "")
        XCTAssertEqual(all.count, results.count)
    }
}
