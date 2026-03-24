# VIPER-Combine-Starter

> A clean iOS starter template demonstrating event-driven VIPER architecture with Combine and Coordinator navigation. Ready to clone and build on.

![Swift](https://img.shields.io/badge/Swift-5.9-orange) ![Platform](https://img.shields.io/badge/Platform-iOS%2016+-blue) ![License](https://img.shields.io/badge/License-MIT-green)

## Why VIPER + Combine?

Standard VIPER uses protocols and delegates everywhere — it works but creates boilerplate. This template replaces delegate chains with Combine publishers, making data flow reactive and reducing coupling between layers.

The Coordinator pattern sits on top, owning all navigation — so modules never reference each other directly.

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    AppCoordinator                        │
│            (owns UINavigationController)                 │
│   Subscribes to Router navigation publishers             │
│                         │                                │
│              ┌──────────▼──────────┐                     │
│              │   Listing Module    │                      │
│              │  (VIPER layers)     │                      │
│              │                     │                      │
│              │  View ──► Presenter │                      │
│              │            │    │   │                      │
│              │            ▼    ▼   │                      │
│              │     Interactor  Router ──► Coordinator     │
│              │            │        │                      │
│              │            ▼        │                      │
│              │         Entity      │                      │
│              └─────────────────────┘                      │
└─────────────────────────────────────────────────────────┘

View       = SwiftUI, observes Presenter's @Published state
Presenter  = Transforms interactor output → view state via Combine
Interactor = Business logic, async/await
Entity     = Plain model structs
Router     = Emits navigation events via PassthroughSubject
Coordinator = Subscribes to Router publishers, owns navigation
```

## What's included

| Layer | File | Responsibility |
|-------|------|---------------|
| **View** | `ListingsListView.swift` | SwiftUI view observing presenter's `@Published` state |
| **Presenter** | `ListingsPresenter.swift` | Transforms interactor output → view state; debounced search via Combine |
| **Interactor** | `ListingsInteractor.swift` | Business logic, async data fetching and search filtering |
| **Entity** | `ListingEntity.swift` | `Listing` model + `ListingViewState` and `ListingNavigationEvent` enums |
| **Router** | `ListingsRouter.swift` | Navigation intents via `PassthroughSubject`, forwarded to Coordinator |
| **Assembly** | `ListingAssembly.swift` | Factory that builds the module with dependency injection |
| **Coordinator** | `AppCoordinator.swift` | Subscribes to router publishers, manages `UINavigationController` |
| **Core** | `Coordinator.swift` | Base `Coordinator` protocol with child coordinator management |
| **Core** | `CombineExtension.swift` | `Publisher.firstValue()` and `Task.publisher()` async/Combine bridges |

## Key patterns demonstrated

- **Combine-driven data flow** — Presenter publishes `ListingViewState` via `@Published`; View observes via `@ObservedObject`
- **Debounced search** — Search query piped through `debounce(300ms)` + `removeDuplicates()` before hitting the interactor
- **Coordinator navigation** — Router emits `ListingNavigationEvent` via `PassthroughSubject`; AppCoordinator subscribes and handles transitions
- **Protocol-oriented assembly** — Every VIPER layer has a protocol (`ListingInteractorProtocol`, `ListingPresenterProtocol`, `ListingRouterProtocol`); `ListingAssembly.build()` wires them together
- **Async interactors** — Business logic uses `async/await`, bridged to Combine in the presenter via `Task`
- **@MainActor presenter** — Thread-safe UI state updates without manual `DispatchQueue.main.async`
- **Testable by design** — Mock interactor and router included in tests; 7 unit tests covering presenter state, navigation, and interactor logic

## Project structure

```
VIPERCoordinator/
├── VIPERCoordinator/
│   ├── App/
│   │   ├── VIPERCoordinatorApp.swift     # @main entry point, AppState wrapper
│   │   └── AppCoordinator.swift          # Root coordinator, navigation handling
│   ├── Core/
│   │   ├── Coordinator.swift             # Base Coordinator protocol
│   │   └── CombineExtension.swift        # Async ↔ Combine bridges
│   └── Modules/
│       └── Listing/
│           ├── ListingsListView.swift     # SwiftUI list with search
│           ├── ListingsPresenter.swift    # @Published state + Combine bindings
│           ├── ListingsInteractor.swift   # Async fetch + search logic
│           ├── ListingsRouter.swift       # Navigation event publisher
│           ├── ListingAssembly.swift      # Module factory
│           └── ListingEntity.swift        # Models + view state enum
├── VIPERCoordinatorTests/
│   └── VIPERCoordinatorTests.swift        # Presenter + Interactor tests with mocks
└── VIPERCoordinator.xcodeproj/
```

## Data flow

**Loading listings:**
1. View calls `presenter.onAppear()`
2. Presenter sets `viewState = .loading`, calls `interactor.fetchListings()` in a `Task`
3. Interactor returns listings (async)
4. Presenter sets `viewState = .loaded(listings)`
5. View redraws via `@ObservedObject`

**Search:**
1. View binds to `presenter.searchQuery` via `.searchable`
2. Presenter pipes `$searchQuery` through `debounce(0.3s)` → `removeDuplicates()`
3. Debounced value triggers `interactor.searchListings(query:)`
4. Presenter updates `viewState` with filtered results

**Navigation:**
1. View calls `presenter.onTapListing(_:)` or `presenter.onTapFilter()`
2. Presenter calls router method
3. Router sends event via `PassthroughSubject`
4. AppCoordinator receives event and pushes/presents the next screen

## Running

Open `VIPERCoordinator/VIPERCoordinator.xcodeproj` in Xcode, select an iOS 16+ simulator, and run.

## Testing

```bash
xcodebuild test \
  -project VIPERCoordinator/VIPERCoordinator.xcodeproj \
  -scheme VIPERCoordinator \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

## License

MIT
