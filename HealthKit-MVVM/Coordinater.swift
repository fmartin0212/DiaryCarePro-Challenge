//
//  Coordinater.swift
//  HealthKit-MVVM
//
//  Created by Frank Martin on 4/11/19.
//  Copyright © 2019 Frank Martin. All rights reserved.
//

import Foundation
import UIKit

final class Coordinator: CoordinatorProtocol {
    let dependencies: Dependencies
    let navigationController: UINavigationController
    
    init(with dependencies: Dependencies, and action: CoordinatorAction) {
        self.dependencies = dependencies
        self.navigationController = UINavigationController()
        self.navigationController.definesPresentationContext = true
        handle(action)
    }
    
    func handle(_ coordinatorAction: CoordinatorAction) {
        switch coordinatorAction {
        case .showList:
            let heartRateListViewModel = HeartRateListViewModel(healthKitService: dependencies.healthKitService,
                                                                coordinator: self)
            let heartRateListViewController = HeartRateListViewController(heartRateViewModel: heartRateListViewModel)
            heartRateListViewModel.delegate = heartRateListViewController
            navigationController.pushViewController(heartRateListViewController, animated: true)
        case .presentAddHeartRateVC:
            let addHeartRateViewModel = AddHeartRateViewModel(coordinator: self, healthKitService: dependencies.healthKitService)
            let addHeartRateViewController = AddHeartRateViewController(viewModel: addHeartRateViewModel)
            navigationController.present(addHeartRateViewController, animated: true, completion: nil)
        case .dismiss:
            navigationController.presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }
}

enum CoordinatorAction {
    case showList
    case presentAddHeartRateVC
    case dismiss
}

protocol CoordinatorProtocol {
    func handle(_ coordinatorAction: CoordinatorAction)
}
