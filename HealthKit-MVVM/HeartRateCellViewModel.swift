//
//  HeartRateCellViewModel.swift
//  HealthKit-MVVM
//
//  Created by Frank Martin on 4/11/19.
//  Copyright © 2019 Frank Martin. All rights reserved.
//

import Foundation
import HealthKit

struct HeartRateCellViewModel {
    
    // MARK: - Properties
    
    let heartRate: HKQuantitySample
    var heartRateValue: String {
        return "\(heartRate.quantity) bpms"
    }
    var startDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: heartRate.startDate)
    }
    
    // MARK: - Initialization
    
    init(heartRate: HKQuantitySample) {
        self.heartRate = heartRate
    }
}
