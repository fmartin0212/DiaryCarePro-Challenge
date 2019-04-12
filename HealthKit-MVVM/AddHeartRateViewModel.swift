//
//  AddHeartRateViewModel.swift
//  HealthKit-MVVM
//
//  Created by Frank Martin on 4/12/19.
//  Copyright © 2019 Frank Martin. All rights reserved.
//

import Foundation

struct AddHeartRateViewModel {
    
    let coordinator: CoordinatorProtocol
    let healthKitService: HealthKitServiceProtocol
    
    init(coordinator: CoordinatorProtocol, healthKitService: HealthKitServiceProtocol) {
        self.coordinator = coordinator
        self.healthKitService = healthKitService
    }
    
    func addHeartRateWith(value: String, startDate: Date, endDate: Date) {
        
    }
}
