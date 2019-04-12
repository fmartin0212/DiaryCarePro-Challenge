//
//  HealthKitService.swift
//  HealthKit-MVVM
//
//  Created by Frank Martin on 4/11/19.
//  Copyright © 2019 Frank Martin. All rights reserved.
//

import Foundation
import HealthKit

protocol HealthKitServiceDelegate: HealthKitServiceProtocolDelegate {}

class HealthKitService: HealthKitServiceProtocol {
    
    // MARK: - Properties
    
    var healthStore: HKHealthStore = HKHealthStore()
    var delegate: HealthKitServiceProtocolDelegate?
    var anchor: HKQueryAnchor?
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        if HKHealthStore.isHealthDataAvailable() {
            let type = HKObjectType.quantityType(forIdentifier: .heartRate)!
            healthStore.requestAuthorization(toShare: [type], read: [type]) { (success, error) in
                if let error = error {
                    print("Error obtaining Health Kit permissions: \(error.localizedDescription)")
                    completion(false)
                } else {
                    completion(success)
                }
            }
        } else {
            completion(false)
        }
    }
    
    func addObserver() {
        let heartRate = HKObjectType.quantityType(forIdentifier: .heartRate)!
        
        let observerQuery = HKObserverQuery(sampleType: heartRate, predicate: nil) { (query, _, error) in
            if let error = error {
                print("There was an error retrieving the heart rate samples: \(error.localizedDescription)")
            }
            let anchoredQuery = HKAnchoredObjectQuery(type: heartRate, predicate: nil, anchor: self.anchor, limit: 0, resultsHandler: { (query, newSamples, deletedSamples, anchor, error) in
                
                if let error = error {
                    print("There was an error executing the anchored query: \(error.localizedDescription)")
                    return
                }
                
                self.delegate?.updateSamples(newSamples: newSamples, deletedSamples: nil)
              
                self.anchor = anchor
                
                query.updateHandler = { (query, newSamples, deletedSamples, anchor, error) in
                    if let error = error {
                        print("There was an error executing the anchored query: \(error.localizedDescription)")
                        return
                    }
                    
                    self.delegate?.updateSamples(newSamples: newSamples, deletedSamples: nil)
                    
                    self.anchor = anchor
                }
            })
            self.healthStore.execute(anchoredQuery)
        }
        healthStore.execute(observerQuery)
    }
    
    func fetchHeartRates(completion: @escaping ([HKQuantitySample]?) -> Void) {
        let heartRate = HKObjectType.quantityType(forIdentifier: .heartRate)!
        if healthStore.authorizationStatus(for: heartRate) == .sharingAuthorized {
            
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
            let query = HKSampleQuery(sampleType: heartRate, predicate: nil, limit: 0, sortDescriptors: [sortDescriptor]) { (_, heartRates, error) in
                if let error = error {
                    print("There was an error fetching the heart rate samples: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                guard let heartRates = heartRates as? [HKQuantitySample] else { completion(nil) ; return }
                completion(heartRates)
            }
            healthStore.execute(query)
        }
    }
}

protocol HealthKitServiceProtocol {
    var healthStore: HKHealthStore { get set }
    var delegate: HealthKitServiceProtocolDelegate? { get set }
    func requestAuthorization(completion: @escaping (Bool) -> Void)
    func addObserver()
    
//    func addHeartRate(completion: @escaping (Bool) -> Void)
    func fetchHeartRates(completion: @escaping ([HKQuantitySample]?) -> Void)
}

protocol HealthKitServiceProtocolDelegate {
    func updateSamples(newSamples: [HKSample]?, deletedSamples: [HKDeletedObject]?)
}
