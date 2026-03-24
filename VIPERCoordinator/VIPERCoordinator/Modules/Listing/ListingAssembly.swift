//
//  ListingAssembly.swift
//  VIPERCoordinator
//
//  Created by Preet Singh on 3/01/26.
//

import SwiftUI
import UIKit

/// Factory that assembles the Listing module's VIPER layers.
enum ListingAssembly {
    
    struct Module {
        let viewController: UIViewController
        let router: ListingRouter
    }
    
    static func build() -> Module {
        let interactor = ListingInteractor()
        let router = ListingRouter()
        let presenter = ListingPresenter(interactor: interactor, router: router)
        let view = ListingListView(presenter: presenter)
        let hostingController = UIHostingController(rootView: view)
        
        return Module(viewController: hostingController, router: router)
    }
}
