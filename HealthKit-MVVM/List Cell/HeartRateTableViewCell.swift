//
//  HeartRateTableViewCell.swift
//  HealthKit-MVVM
//
//  Created by Frank Martin on 4/11/19.
//  Copyright © 2019 Frank Martin. All rights reserved.
//

import UIKit

final class HeartRateTableViewCell: UITableViewCell {

    // MARK: - Properties
    
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var heartRateLabel: UILabel!
    static let identifier = "heartRateCell"
    static let nibName = "HeartRateTableViewCell"
    
    func configure(with viewModel: HeartRateCellViewModel) {
        self.dateLabel.text = viewModel.startDate
        self.heartRateLabel.text = viewModel.heartRateValue
    }
}
