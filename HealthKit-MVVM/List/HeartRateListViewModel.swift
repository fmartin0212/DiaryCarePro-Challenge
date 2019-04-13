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
    private let type = HKObjectType.quantityType(forIdentifier: .heartRate)!
    
    // MARK: - Initialization
    
    init(healthKitService: HealthKitServiceProtocol, coordinator: CoordinatorProtocol) {
        self.healthKitService = healthKitService
        self.coordinator = coordinator
        if healthKitService.healthStore.authorizationStatus(for: type) == .sharingAuthorized {
            self.healthKitService.addObserver()
        }
        self.healthKitService.delegate = self
    }
    
    func checkAuthorization(completion: @escaping (Result<Bool, HealthKitError>) -> Void) {
        healthKitService.checkAuthorizationStatus(for: type) { (result) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(_):
                completion(.success(true))
            }
        }
    }
    
    func delete(_ cellViewModel: HeartRateCellViewModel, viewController: HeartRateListViewController, completion: @escaping (Result<Bool, HealthKitError>) -> Void) {
        let object = cellViewModel.heartRate as HKObject
        healthKitService.delete(object: object) { [weak self] (result) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(_):
                guard let index = self?.heartRateCellViewModels.firstIndex(of: cellViewModel) else { return }
                self?.heartRateCellViewModels.remove(at: index)
                completion(.success(true))
            }
            
        }
    }
}

extension HeartRateListViewModel: HealthKitServiceProtocolDelegate {
    
    func updateSamples(newSamples: [HKSample]?, isIncremental: Bool) {
        if let newSamples = newSamples {
            if isIncremental {
                newSamples.forEach {
                    guard let quantitySample = $0 as? HKQuantitySample else { return }
                    let heartRateCellViewModel = HeartRateCellViewModel(heartRate: quantitySample)
                    heartRateCellViewModels.append(heartRateCellViewModel)
                }
            } else {
                self.heartRateCellViewModels = newSamples.compactMap {
                    guard let quantitySample = $0 as? HKQuantitySample else { return nil }
                    return HeartRateCellViewModel(heartRate: quantitySample)
                }
            }
            delegate?.heartRatesWereUpdated()
        }
    }
}
