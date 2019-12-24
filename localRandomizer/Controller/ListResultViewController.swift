//
//  ListResultViewController.swift
//  localRandomizer
//
//  Created by Roman Trekhlebov on 14/09/2019.
//  Copyright © 2019 Roman Trekhlebov. All rights reserved.
//

import UIKit
import RealmSwift
import Firebase

class ListResultViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var randomiseBtn: UIButton!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    var notificationToken: NotificationToken? = nil
    
    var listViewModel = ListResultTotalViewModel()
    var personList : [String]!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView?.dataSource = self
        tableView?.delegate = self
        indicator.hidesWhenStopped = true
        listViewModel.fillStroredResults()

        // Do any additional setup after loading the view.
        // Observe Results Notifications
        
        notificationToken = listViewModel.getAllResults().observe { [weak self] (changes: RealmCollectionChange) in
            guard let tableView = self?.tableView else { return }
            switch changes {
            case .initial:
                // Results are now populated and can be accessed without blocking the UI
                tableView.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                // Query results have changed, so apply them to the UITableView
                tableView.beginUpdates()
                // Always apply updates in the following order: deletions, insertions, then modifications.
                // Handling insertions before deletions may result in unexpected behavior.
                tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}),
                                     with: .automatic)
                tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
                                     with: .automatic)
                tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
                                     with: .automatic)
                
                tableView.endUpdates()
                
                if insertions.count > 0 {
                    DispatchQueue.main.async {
                        self!.tableView.scrollToRow(at: IndexPath(row: self!.listViewModel.totalItems() - 1, section: 0), at: .bottom, animated: true)
                    }
                }
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if self.listViewModel.totalItems() > 1 {
            DispatchQueue.main.async {
                self.tableView.scrollToRow(at: IndexPath(row: self.listViewModel.totalItems() - 1, section: 0), at: .bottom, animated: true)
            }
        }
        
    }
    
    deinit {
        notificationToken?.invalidate()
    }
    
    @IBAction func trashBtnWasPressed(_ sender: Any) {
        
        RealmService().removeAllResults()
        // Analytics
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: "Id-Btn-Trash",
        AnalyticsParameterItemName: "ArchiveTrashBtn",
        AnalyticsParameterContentType: "ClearArchive"
        ])
        //
    }
    
    
    @IBAction func randomiseBtnWasPressed(_ sender: Any) {
        self.personList = PersonListViewModel().getPersonsStringArray()
        
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
                // Analytics
                Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                    AnalyticsParameterItemID: "Id-Btn",
                AnalyticsParameterItemName: "ArchiveRandomBtn",
                AnalyticsParameterContentType: "RandomizeUsed"
                ])
                //
                
                
                
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
