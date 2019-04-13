//
//  HealthKitService.swift
//  HealthKit-MVVM
//
//  Created by Frank Martin on 4/11/19.
//  Copyright © 2019 Frank Martin. All rights reserved.
//

import Foundation
import HealthKit

protocol HealthKitServiceProtocol {
    var healthStore: HKHealthStore { get set }
    var delegate: HealthKitServiceProtocolDelegate? { get set }
    func checkAuthorizationStatus(for type: HKObjectType, completion: @escaping (Bool) -> Void)
    func requestAuthorization(for type: HKObjectType, completion: @escaping (Bool) -> Void)
    func addObserver()
    func saveHeartRate(withValue value: Double, startDate: Date, endDate: Date, completion: @escaping (Bool) -> Void)
    func delete(object: HKObject, completion: @escaping (Bool) -> Void)
}

protocol HealthKitServiceProtocolDelegate {
    func updateSamples(newSamples: [HKSample]?, isIncremental: Bool)
}

protocol HealthKitServiceDelegate: HealthKitServiceProtocolDelegate {}

class HealthKitService: HealthKitServiceProtocol {
   
    // MARK: - Properties
    
    var healthStore: HKHealthStore = HKHealthStore()
    var delegate: HealthKitServiceProtocolDelegate?
    var anchor: HKQueryAnchor?
    
    // Would add additional error handling here
    func checkAuthorizationStatus(for type: HKObjectType, completion: @escaping (Bool) -> Void) {
        if HKHealthStore.isHealthDataAvailable() {
            switch healthStore.authorizationStatus(for: type) {
            case .notDetermined:
                    requestAuthorization(for: type, completion: { [weak self] (success) in
                        if success {
                            completion(true)
                             self?.addObserver()
                        } else {
                            completion(false)
                        }
                    })
            case .sharingAuthorized:
                completion(true)
            case .sharingDenied:
                completion(false)
            @unknown default:
                completion(false)
            }
        }
    }
    
    func requestAuthorization(for type: HKObjectType, completion: @escaping (Bool) -> Void) {
        if HKHealthStore.isHealthDataAvailable() {
            let heartRate = HKObjectType.quantityType(forIdentifier: .heartRate)!
            healthStore.requestAuthorization(toShare: [heartRate], read: [heartRate]) { (success, error) in
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
        
        let observerQuery = HKObserverQuery(sampleType: heartRate, predicate: nil) { [weak self] (query, _, error) in
            if let error = error {
                print("There was an error retrieving the heart rate samples: \(error.localizedDescription)")
            }
            let anchoredQuery = HKAnchoredObjectQuery(type: heartRate, predicate: nil, anchor: self?.anchor, limit: 0, resultsHandler: { (query, newSamples, deletedSamples, anchor, error) in
                
                if let error = error {
                    print("There was an error executing the anchored query: \(error.localizedDescription)")
                    return
                }
                let isIncremental: Bool = self?.anchor == nil ? false : true
                self?.delegate?.updateSamples(newSamples: newSamples, isIncremental: isIncremental)
                self?.anchor = anchor
            })
            self?.healthStore.execute(anchoredQuery)
        }
        healthStore.execute(observerQuery)
    }
    
    func saveHeartRate(withValue value: Double, startDate: Date, endDate: Date, completion: @escaping (Bool) -> Void) {
        let heartRate = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let sample = HKQuantitySample(type: heartRate, quantity: HKQuantity(unit: HKUnit.count().unitDivided(by: .minute()), doubleValue: value ), start: startDate, end: endDate, device: HKDevice.local(), metadata: nil)
        
        if healthStore.authorizationStatus(for: heartRate) == .sharingAuthorized {
            healthStore.save(sample, withCompletion: { (success, error) in
                if let error = error {
                    print("There was an error saving the heart rate: \(error.localizedDescription)")
                    completion(false)
                    return
                }
                completion(true)
            })
        }
    }
    
    func delete(object: HKObject, completion: @escaping (Bool) -> Void) {
        healthStore.delete(object) { (success, error) in
            if let error = error {
                print("There was an error deleting an HKObject: \(error.localizedDescription)")
                completion(false)
                return
            }
            if success {
                completion(true)
            }
        }
    }
}
