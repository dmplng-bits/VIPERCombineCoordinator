//
//  listingEntity.swift
//  VIPERCoordinator
//
//  Created by Preet Singh on 3/01/26.
//

import Foundation

struct Listing: Identifiable, Equatable, Sendable {
    let id: UUID
    let title: String
    let subtitle: String
    let price: String
    let rating: Double
    let imageURL: URL?
    
    static let preview = Listing(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
        title: "Modern Studio Apartment",
        subtitle: "Downtown · 1 bed · WiFi",
        price: "$89/night",
        rating: 4.7,
        imageURL: nil
    )
}

/// View state emitted by presenter, consumed by SwiftUI view.
enum ListingViewState: Equatable {
    case idle
    case loading
    case loaded([Listing])
    case error(String)
}

/// Navigation events emitted by router.
enum ListingNavigationEvent: NavigationEvent {
    case showDetail(Listing)
    case showFilter
}

