//
//  AddHeartRateViewModel.swift
//  HealthKit-MVVM
//
//  Created by Frank Martin on 4/12/19.
//  Copyright © 2019 Frank Martin. All rights reserved.
//

import Foundation

struct AddHeartRateViewModel {
    
    // MARK: - Properties
    
    let coordinator: CoordinatorProtocol
    let healthKitService: HealthKitServiceProtocol
    let initialDate = Date().asFormattedString()
    
    init(coordinator: CoordinatorProtocol, healthKitService: HealthKitServiceProtocol) {
        self.coordinator = coordinator
        self.healthKitService = healthKitService
    }
    
    func saveHeartRate(withValue value: String, startDate: Date, endDate: Date, viewController: AddHeartRateViewController, completion: @escaping (Result<Bool, HealthKitError>) -> Void) {
        guard let value = Double(value), value >= Constant.fifty && value <= Constant.twoHundred
            else { coordinator.handle(.presentAlertController(error: .invalidEntry, vc: viewController)) ; return }
        healthKitService.saveHeartRate(withValue: value, startDate: startDate, endDate: endDate) { (result) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(_):
                completion(.success(true))
            }
        }
    }
}
