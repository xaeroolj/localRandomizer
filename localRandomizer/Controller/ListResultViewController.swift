//
//  ListResultViewController.swift
//  localRandomizer
//
//  Created by Roman Trekhlebov on 14/09/2019.
//  Copyright © 2019 Roman Trekhlebov. All rights reserved.
//

import UIKit

class ListResultViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var randomiseBtn: UIButton!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    var listViewModel = ListResultTotalViewModel()
    var personList : [String]!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView?.dataSource = self
        tableView?.delegate = self
        indicator.hidesWhenStopped = true

        // Do any additional setup after loading the view.
    }
    @IBAction func randomiseBtnWasPressed(_ sender: Any) {
        
        if personList.count <= 1 {
            return
        }
        randomiseBtn.isEnabled = false
        indicator.startAnimating()
        
        RandomService.instance.randomForList(personList) { (result) in
            DispatchQueue.main.async {
                self.indicator.stopAnimating()
                self.randomiseBtn.isEnabled = true
            }
            switch result {
            case .success(let successArray):
                //                print(successArray)
                let totalString: String = successArray.joined(separator: ", ")
                let resultModel = ListResultModel(date: Date(), resultString: totalString)
                let resultViewModel = ListResultViewModel(resultModel)
                self.listViewModel.addViewModel(resultViewModel)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.tableView.scrollToRow(at: IndexPath(row: self.listViewModel.totalItems() - 1, section: 0), at: .bottom, animated: true)
                }
                
            case .failure(let error):
                self.showAllert(title: "Error:", message: error.localizedDescription, action: nil)
                //                fatalError(error.localizedDescription)
            }
            
            
            
        }
    }

    func showAllert(title: String, message: String, action: UIAlertAction?) {
        
        let allertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if let action = action {
            
            allertController.addAction(action)
        } else {
            let actionOK = UIAlertAction(title: "Ok", style: .default, handler: nil)
            
            allertController.addAction(actionOK)
        }
        
        DispatchQueue.main.async {
            self.present(allertController, animated: true, completion: nil)
            
        }
        
    }
}
extension ListResultViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listViewModel.totalItems()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "resultCell", for: indexPath) as? ListResultTableViewCell else {return UITableViewCell()}
        cell.initCell(self.listViewModel.viewModelFor(index: indexPath.row))
        
        return cell
    }
    
    
}
