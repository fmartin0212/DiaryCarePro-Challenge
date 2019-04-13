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
    let type = HKObjectType.quantityType(forIdentifier: .heartRate)!
    
    // MARK: - Initialization
    
    init(healthKitService: HealthKitServiceProtocol, coordinator: CoordinatorProtocol) {
        self.healthKitService = healthKitService
        self.coordinator = coordinator
        if healthKitService.healthStore.authorizationStatus(for: self.type) == .sharingAuthorized {
            self.healthKitService.addObserver()
        }
        self.healthKitService.delegate = self
    }
    
    func checkAuthorization(completion: @escaping (Bool) -> Void) {
        healthKitService.checkAuthorizationStatus(for: self.type) { (success) in
            completion(success)
        }
    }
    
    func delete(_ cellViewModel: HeartRateCellViewModel, completion: @escaping (Bool) -> Void) {
        let object = cellViewModel.heartRate as HKObject
        healthKitService.delete(object: object) { [unowned self] (success) in
            guard let index = self.heartRateCellViewModels.firstIndex(of: cellViewModel) else { return }
            self.heartRateCellViewModels.remove(at: index)
            completion(true)
        }
    }
}

extension HeartRateListViewModel: HealthKitServiceProtocolDelegate {
    
    func updateSamples(newSamples: [HKSample]?, isIncremental: Bool) {
        if let newSamples = newSamples {
            if isIncremental {
                newSamples.forEach { self.heartRateCellViewModels.append(HeartRateCellViewModel(heartRate: $0 as! HKQuantitySample)) }
            } else {
                self.heartRateCellViewModels = newSamples.map { HeartRateCellViewModel(heartRate: $0 as! HKQuantitySample) }
            }
        }
        
        delegate?.heartRatesWereUpdated()
    }
}
