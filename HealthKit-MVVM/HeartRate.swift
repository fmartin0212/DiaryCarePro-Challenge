//
//  HeartRate.swift
//  HealthKit-MVVM
//
//  Created by Frank Martin on 4/11/19.
//  Copyright © 2019 Frank Martin. All rights reserved.
//

import Foundation

public struct HeartRate {
    
    // MARK: - Properties
    
    let heartRate: Double
    let date: Date
    
    // MARK: - Initialization
    
    init(heartRate: Double, date: Date) {
        self.heartRate = heartRate
        self.date = date
    }
}
