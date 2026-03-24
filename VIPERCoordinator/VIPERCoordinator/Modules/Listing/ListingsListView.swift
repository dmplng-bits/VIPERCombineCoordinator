//
//  ListingListView.swift
//  VIPERCoordinator
//
//  Created by Preet Singh on 3/22/26.
//

import SwiftUI

/// SwiftUI view that observes the presenter's published state.
struct ListingListView<P: ListingPresenterProtocol>: View {
    @ObservedObject var presenter: P
    
    var body: some View {
        Group {
            switch presenter.viewState {
            case .idle:
                Color.clear.onAppear { presenter.onAppear() }
                
            case .loading:
                ProgressView("Loading listings...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            case .loaded(let listings):
                listContent(listings)
                
            case .error(let message):
                errorView(message)
            }
        }
        .navigationTitle("Listings")
        .searchable(text: $presenter.searchQuery, prompt: "Search listings")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { presenter.onTapFilter() } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    private func listContent(_ listings: [Listing]) -> some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(listings) { listing in
                    listingRow(listing)
                        .onTapGesture { presenter.onTapListing(listing) }
                }
            }
            .padding()
        }
    }
    
    private func listingRow(_ listing: Listing) -> some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.secondary.opacity(0.15))
                .frame(width: 64, height: 64)
                .overlay {
                    Image(systemName: "photo")
                        .foregroundStyle(.tertiary)
                }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(listing.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(listing.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                HStack {
                    Label(String(format: "%.1f", listing.rating), systemImage: "star.fill")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                    Spacer()
                    Text(listing.price)
                        .font(.caption)
                        .fontWeight(.semibold)
                }
            }
        }
        .padding(12)
        .background(.background, in: RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(listing.title), \(listing.subtitle), \(listing.price)")
    }
    
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Button("Retry") { presenter.onAppear() }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
