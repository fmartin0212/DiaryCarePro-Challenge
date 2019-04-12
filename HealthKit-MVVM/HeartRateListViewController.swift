//
//  HeartRateViewController.swift
//  HealthKit-MVVM
//
//  Created by Frank Martin on 4/11/19.
//  Copyright © 2019 Frank Martin. All rights reserved.
//

import UIKit

class HeartRateListViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var tableView: UITableView!
    static private let nibName = "HeartRateListViewController"
    let heartRateListViewModel: HeartRateListViewModel
    
    // MARK: - Initialization
    
    init(heartRateViewModel: HeartRateListViewModel) {
        self.heartRateListViewModel = heartRateViewModel
        super.init(nibName: HeartRateListViewController.nibName, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let heartRateCell = UINib(nibName: HeartRateTableViewCell.nibName, bundle: nil)
        tableView.register(heartRateCell, forCellReuseIdentifier: HeartRateTableViewCell.identifier)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(presentAddHeartRateVC))
    }
    
    @objc func presentAddHeartRateVC() {
        heartRateListViewModel.coordinator.handle(.presentAddHeartRateVC)
    }
}

extension HeartRateListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return heartRateListViewModel.heartRateCellViewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HeartRateTableViewCell.identifier, for: indexPath) as? HeartRateTableViewCell else { return UITableViewCell() }
        let heartRateCellViewModel = heartRateListViewModel.heartRateCellViewModels[indexPath.row]
        cell.configure(with: heartRateCellViewModel)

        return cell
    }
}

extension HeartRateListViewController: HeartHeartRateListViewModelDelegate {
    
    func heartRatesWereUpdated() {
        DispatchQueue.main.async { [unowned self] in
           self.tableView.reloadData()
        }
    }
}
