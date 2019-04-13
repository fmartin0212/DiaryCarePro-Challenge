//
//  HeartRateCellViewModel.swift
//  HealthKit-MVVM
//
//  Created by Frank Martin on 4/11/19.
//  Copyright © 2019 Frank Martin. All rights reserved.
//

import Foundation
import HealthKit

struct HeartRateCellViewModel: Equatable {
    
    // MARK: - Properties
    
    let heartRate: HKQuantitySample
    var heartRateValue: String {
        let rawValue = heartRate.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute())).rounded(.down)
        
        return "\(rawValue) bpm"
    }
    var startDate: String {
      return heartRate.startDate.asFormattedString()
    }
    
    // MARK: - Initialization
    
    init(heartRate: HKQuantitySample) {
        self.heartRate = heartRate
    }
}

