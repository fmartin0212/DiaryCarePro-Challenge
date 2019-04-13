//
//  Extensions.swift
//  HealthKit-MVVM
//
//  Created by Frank Martin on 4/12/19.
//  Copyright © 2019 Frank Martin. All rights reserved.
//

import Foundation

extension Date {
    
    func asFormattedString() -> String {
        DateFormatter.shared.dateStyle = .short
        DateFormatter.shared.timeStyle = .short
        return DateFormatter.shared.string(from: self)
    }
}

extension DateFormatter {
    static let shared = DateFormatter()
}
