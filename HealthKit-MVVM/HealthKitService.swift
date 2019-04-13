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
    var type: HKQuantityType { get set }
    func checkAuthorizationStatus(for type: HKObjectType, completion: @escaping (Result<Bool, HealthKitError>) -> Void)
    func requestAuthorization(for type: HKObjectType, completion: @escaping (Result<Bool, HealthKitError>) -> Void)
    func addObserver()
    func saveHeartRate(withValue value: Double, startDate: Date, endDate: Date, completion: @escaping (Result<Bool, HealthKitError>) -> Void)
    func delete(object: HKObject, completion: @escaping (Result<Bool, HealthKitError>) -> Void)
}

protocol HealthKitServiceProtocolDelegate {
    func updateSamples(newSamples: [HKSample]?, isIncremental: Bool)
}

protocol HealthKitServiceDelegate: HealthKitServiceProtocolDelegate {}

enum HealthKitError: String, Error  {
    case healthDataNotAvailable = "Sorry, health data is not available on this device."
    case sharingDenied = "You have denied authorization to share data with Apple Health. Please authorize in order to use this feature."
    case genericFailure = "There was an error while trying to process your request. Please try again."
    case saving = "There was an error saving to Apple Health. Please try again."
    case deleting = "There was an error deleting from Apple Health. Please try again."
    case invalidEntry = "Please enter a valid heart rate that is no less than 50 and no greater than 200 bpm."
}

class HealthKitService: HealthKitServiceProtocol {
   
    // MARK: - Properties
    
    var healthStore: HKHealthStore = HKHealthStore()
    var delegate: HealthKitServiceProtocolDelegate?
    var anchor: HKQueryAnchor?
    var type: HKQuantityType = HKObjectType.quantityType(forIdentifier: .heartRate)!
    
    func checkAuthorizationStatus(for type: HKObjectType, completion: @escaping (Result<Bool, HealthKitError>) -> Void) {
        if !HKHealthStore.isHealthDataAvailable() {
            completion(.failure(.healthDataNotAvailable))
            return
        }
        
        switch healthStore.authorizationStatus(for: type) {
        case .notDetermined:
            requestAuthorization(for: type, completion: { [weak self] (result) in
                switch result {
                case .failure(let error):
                    completion(.failure(error))
                case .success(let success):
                    self?.addObserver()
                    completion(.success(success))
                }
            })
        case .sharingAuthorized:
            completion(.success(true))
        case .sharingDenied:
            completion(.failure(.sharingDenied))
        @unknown default:
            completion(.failure(.genericFailure))
        }
    }
    
    func requestAuthorization(for type: HKObjectType, completion: @escaping (Result<Bool, HealthKitError>) -> Void) {
        if !HKHealthStore.isHealthDataAvailable() {
            completion(.failure(.healthDataNotAvailable))
            return
        }
        let heartRate = HKObjectType.quantityType(forIdentifier: .heartRate)!
        healthStore.requestAuthorization(toShare: [heartRate], read: [heartRate]) { (success, error) in
            if let error = error {
                print("Error obtaining Health Kit permissions: \(error.localizedDescription)")
                completion(.failure(.genericFailure))
            } else {
                completion(.success(true))
            }
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
    
    func saveHeartRate(withValue value: Double, startDate: Date, endDate: Date, completion: @escaping (Result<Bool, HealthKitError>) -> Void) {
        if !HKHealthStore.isHealthDataAvailable() {
            completion(.failure(.healthDataNotAvailable))
            return
        }
   
        checkAuthorizationStatus(for: type) { [weak self] (result) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(_):
                let heartRate = HKQuantityType.quantityType(forIdentifier: .heartRate)!
                let sample = HKQuantitySample(type: heartRate, quantity: HKQuantity(unit: HKUnit.count().unitDivided(by: .minute()), doubleValue: value ), start: startDate, end: endDate, device: HKDevice.local(), metadata: nil)
                
                if self?.healthStore.authorizationStatus(for: heartRate) == .sharingAuthorized {
                    self?.healthStore.save(sample, withCompletion: { (success, error) in
                        if let error = error {
                            print("There was an error saving the heart rate: \(error.localizedDescription)")
                            completion(.failure(.genericFailure))
                            return
                        }
                        if success {
                            completion(.success(true))
                        } else {
                            completion(.failure(.saving))
                        }
                    })
                }
            }
        }
    }
    
    func delete(object: HKObject, completion: @escaping (Result<Bool, HealthKitError>) -> Void) {
        if !HKHealthStore.isHealthDataAvailable() {
            completion(.failure(.healthDataNotAvailable))
            return
        }
        checkAuthorizationStatus(for: type) { [weak self] (result) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(_):
                self?.healthStore.delete(object) { (success, error) in
                    if let error = error {
                        print("There was an error deleting an HKObject: \(error.localizedDescription)")
                        completion(.failure(.genericFailure))
                        return
                    }
                    if success {
                        completion(.success(true))
                    } else {
                        completion(.failure(.saving))
                    }
                }
            }
        }
    }
}
