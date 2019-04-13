//
//  AddHeartRateViewController.swift
//  HealthKit-MVVM
//
//  Created by Frank Martin on 4/12/19.
//  Copyright © 2019 Frank Martin. All rights reserved.
//

import UIKit

final class AddHeartRateViewController: UIViewController {

    // MARK: - Properties
    
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var bpmTextField: UITextField!
    @IBOutlet private weak var startDateTextField: UITextField!
    @IBOutlet private weak var endDateTextField: UITextField!
    static private let nibName = "AddHeartRateViewController"
    private let addHeartRateViewModel: AddHeartRateViewModel
    private let startDatePicker = UIDatePicker()
    private let endDatePicker = UIDatePicker()
    
    // MARK: - Initialization
    
    init(addHeartRateViewModel: AddHeartRateViewModel) {
        self.addHeartRateViewModel = addHeartRateViewModel
        super.init(nibName: AddHeartRateViewController.nibName, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        addKeyboardObservers()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupViews() {
        startDateTextField.inputView = startDatePicker
        startDatePicker.maximumDate = Date()
        startDateTextField.text = addHeartRateViewModel.initialDate
        endDateTextField.inputView = endDatePicker
        endDatePicker.maximumDate = startDatePicker.date
        endDateTextField.text = addHeartRateViewModel.initialDate
        startDatePicker.addTarget(self, action: #selector(datePickerChanged(sender:)), for: .valueChanged)
        endDatePicker.addTarget(self, action: #selector(datePickerChanged(sender:)), for: .valueChanged)
    }
    
    @objc private func datePickerChanged(sender: UIDatePicker) {
        switch sender {
        case startDatePicker:
            startDateTextField.text = sender.date.asFormattedString()
        case endDatePicker: endDateTextField.text = sender.date.asFormattedString()
        default:
            print("Something went wrong")
        }
    }
    
    private func addKeyboardObservers() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { [scrollView] (notification) in
            guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
            scrollView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height, right: 0)
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { [scrollView] (_) in
            scrollView?.contentInset = UIEdgeInsets.zero
        }
        
    }
    
    @IBAction private func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func saveButtonTapped(_ sender: Any) {
        guard let value = bpmTextField.text, !value.isEmpty else { return }
        addHeartRateViewModel.saveHeartRate(withValue: value, startDate: startDatePicker.date, endDate: endDatePicker.date) { [unowned self] (success) in
            DispatchQueue.main.async {
                if success {
                    self.addHeartRateViewModel.coordinator.handle(.dismiss(vc: self))
                } else {
                    // Handle error; e.g. alert controller
                }
            }
        }
    }
}

extension AddHeartRateViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text,
            let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        return count <= 3
    }
}
