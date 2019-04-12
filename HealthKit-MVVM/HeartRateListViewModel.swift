//
//  HeartRateViewModel.swift
//  HealthKit-MVVM
//
//  Created by Frank Martin on 4/11/19.
//  Copyright © 2019 Frank Martin. All rights reserved.
//

import Foundation
import HealthKit

protocol HeartHeartRateListViewModelDelegate {
    func heartRatesWereUpdated()
}

class HeartRateListViewModel {
    
    // MARK: - Properties
    
    var heartRateCellViewModels: [HeartRateCellViewModel] = []
    var healthKitService: HealthKitServiceProtocol
    let coordinator: CoordinatorProtocol
    var delegate: HeartHeartRateListViewModelDelegate?
    
    // MARK: - Initialization
    
    init(healthKitService: HealthKitServiceProtocol, coordinator: CoordinatorProtocol) {
        self.healthKitService = healthKitService
        self.coordinator = coordinator
        self.healthKitService.delegate = self
        self.healthKitService.addObserver()
    }
    
    func fetchHeartRates(completion: @escaping (Bool) -> Void) {
        healthKitService.fetchHeartRates {  [unowned self] (heartRates) in
            guard let heartRates = heartRates else { completion(false) ; return }
            self.heartRateCellViewModels = heartRates.map { HeartRateCellViewModel(heartRate: $0) }
            completion(true)
        }
    }
}

extension HeartRateListViewModel: HealthKitServiceProtocolDelegate {
    
    func updateSamples(newSamples: [HKSample]?, deletedSamples: [HKDeletedObject]?, isIncremental: Bool) {
        if let newSamples = newSamples {
            if isIncremental {
                newSamples.forEach { self.heartRateCellViewModels.append(HeartRateCellViewModel(heartRate: $0 as! HKQuantitySample)) }
            } else {
                self.heartRateCellViewModels = newSamples.map { HeartRateCellViewModel(heartRate: $0 as! HKQuantitySample) }
            }
        }
        
        if let deletedSamples = deletedSamples as? [HKQuantitySample] {
//            for deletedSample as! HKQuanti in deletedSamples {
//                guard let index =
//            }
        }
        delegate?.heartRatesWereUpdated()
    }
}
