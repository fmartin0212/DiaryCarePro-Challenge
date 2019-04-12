//
//  HeartRateViewModel.swift
//  HealthKit-MVVM
//
//  Created by Frank Martin on 4/11/19.
//  Copyright © 2019 Frank Martin. All rights reserved.
//

import Foundation

class HeartRateListViewModel {
    
    // MARK: - Properties
    
    var heartRateCellViewModels: [HeartRateCellViewModel] = []
    let healthKitService: HealthKitServiceProtocol
    let coordinator: CoordinatorProtocol
    
    // MARK: - Initialization
    
    init(healthKitService: HealthKitServiceProtocol, coordinator: CoordinatorProtocol) {
        self.healthKitService = healthKitService
        self.coordinator = coordinator
        
    }
    
    func fetchHeartRates(completion: @escaping (Bool) -> Void) {
        healthKitService.fetchHeartRates {  [unowned self] (heartRates) in
            guard let heartRates = heartRates else { completion(false) ; return }
            self.heartRateCellViewModels = heartRates.map { HeartRateCellViewModel(heartRate: $0) }
            completion(true)
        }
    }
}
