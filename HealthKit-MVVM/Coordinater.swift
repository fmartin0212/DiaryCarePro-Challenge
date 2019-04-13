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
    
    // MARK: - Properties
    
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
            heartRateListViewController.loadViewIfNeeded()
            heartRateListViewModel.delegate = heartRateListViewController
            navigationController.pushViewController(heartRateListViewController, animated: true)
        case .presentAddHeartRateVC:
            let addHeartRateViewModel = AddHeartRateViewModel(coordinator: self,
                                                              healthKitService: dependencies.healthKitService)
            let addHeartRateViewController = AddHeartRateViewController(addHeartRateViewModel: addHeartRateViewModel)
            navigationController.present(addHeartRateViewController, animated: true, completion: nil)
        case .dismiss(let vc):
            vc.dismiss(animated: true, completion: nil)
        case .presentAlertController(error: let error, vc: let vc):
            let alertController = UIAlertController(title: Constant.oops, message: error.rawValue, preferredStyle: .alert)
            let okAction = UIAlertAction(title: Constant.ok, style: .default, handler: nil)
            alertController.addAction(okAction)
            vc.present(alertController, animated: true, completion: nil)
        }
    }
}

enum CoordinatorAction {
    case showList
    case presentAddHeartRateVC
    case presentAlertController(error: HealthKitError, vc: UIViewController)
    case dismiss(vc: UIViewController)
}

protocol CoordinatorProtocol {
    func handle(_ coordinatorAction: CoordinatorAction)
}
