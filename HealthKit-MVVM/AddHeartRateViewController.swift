//
//  AddHeartRateViewController.swift
//  HealthKit-MVVM
//
//  Created by Frank Martin on 4/12/19.
//  Copyright © 2019 Frank Martin. All rights reserved.
//

import UIKit

class AddHeartRateViewController: UIViewController {

    // MARK: - Properties
    
    @IBOutlet weak var bpmTextField: UITextField!
    @IBOutlet weak var startDateTextField: UITextField!
    @IBOutlet weak var endDateTextField: UITextField!
    static let nibName = "AddHeartRateViewController"
    let viewModel: AddHeartRateViewModel
    let startDatePicker = UIDatePicker()
    let endDatePicker = UIDatePicker()
    
    
    // MARK: - Initialization
    
    init(viewModel: AddHeartRateViewModel) {
        self.viewModel = viewModel
        super.init(nibName: AddHeartRateViewController.nibName, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    func setupViews() {
        startDateTextField.inputView = startDatePicker
        startDatePicker.maximumDate = Date()
        endDateTextField.inputView = endDatePicker
        endDatePicker.maximumDate = startDatePicker.date
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let value = bpmTextField.text, !value.isEmpty else { return }
        viewModel.saveHeartRate(withValue: value, startDate: startDatePicker.date, endDate: endDatePicker.date) { [unowned self] (success) in
            DispatchQueue.main.async {
                if success {
                    self.viewModel.coordinator.handle(.dismiss(vc: self))
                } else {
                    // Handle error; e.g. alert controller
                }
            }
        }
    }
}
