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
    
    func saveHeartRate(withValue value: String, startDate: Date, endDate: Date, completion: @escaping (Bool) -> Void) {
        // Would add additional error coverage here to prevent invalid heart rates from being entered
        guard let value = Double(value), value > Constant.fifty && value < Constant.twoHundred else { return }
        healthKitService.saveHeartRate(withValue: value, startDate: startDate, endDate: endDate) { (success) in
             completion(success)
        }
    }
}
