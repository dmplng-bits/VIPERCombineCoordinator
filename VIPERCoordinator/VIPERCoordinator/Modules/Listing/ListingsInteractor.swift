//
//  ListingInteractor.swift
//  VIPERCoordinator
//
//  Created by Preet Singh on 3/01/26.
//

import Foundation

/// Interactor protocol — enables test injection.
protocol ListingInteractorProtocol: Sendable {
    func fetchListings() async throws -> [Listing]
    func searchListings(query: String) async throws -> [Listing]
}

/// Production interactor. Swap with MockListingInteractor in tests.
final class ListingInteractor: ListingInteractorProtocol {
    
    func fetchListings() async throws -> [Listing] {
        // Simulate network delay
        try await Task.sleep(for: .milliseconds(600))
        return Self.sampleData
    }
    
    func searchListings(query: String) async throws -> [Listing] {
        let all = try await fetchListings()
        guard !query.isEmpty else { return all }
        
        let lowered = query.lowercased()
        return all.filter {
            $0.title.lowercased().contains(lowered) ||
            $0.subtitle.lowercased().contains(lowered)
        }
    }
    
    // MARK: - Sample data 
    
    private static let sampleData: [Listing] = [
        Listing(id: UUID(), title: "Modern Studio Apartment", subtitle: "Downtown · 1 bed · WiFi", price: "$89/night", rating: 4.7, imageURL: nil),
        Listing(id: UUID(), title: "Cozy Treehouse Retreat", subtitle: "Mountain · 2 beds · Hot tub", price: "$145/night", rating: 4.9, imageURL: nil),
        Listing(id: UUID(), title: "Beachfront Bungalow", subtitle: "Coast · 3 beds · Ocean view", price: "$210/night", rating: 4.6, imageURL: nil),
        Listing(id: UUID(), title: "Industrial Loft", subtitle: "Arts District · 1 bed · Rooftop", price: "$120/night", rating: 4.4, imageURL: nil),
        Listing(id: UUID(), title: "Quiet Garden Cottage", subtitle: "Suburbs · 2 beds · Patio", price: "$95/night", rating: 4.8, imageURL: nil),
        Listing(id: UUID(), title: "Penthouse Suite", subtitle: "Financial District · 2 beds · Gym", price: "$350/night", rating: 4.5, imageURL: nil),
    ]
}
