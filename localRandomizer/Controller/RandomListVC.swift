//
//  RandomListVC.swift
//  localRandomizer
//
//  Created by Roman Trekhlebov on 19/04/2019.
//  Copyright © 2019 Roman Trekhlebov. All rights reserved.
//

import UIKit
import RealmSwift

class RandomListVC: UIViewController {
    
    let personListVM = PersonListViewModel()
    var notificationToken: NotificationToken? = nil
    var resultViewModel: ListResultViewModel?
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var newTextField: UITextField!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var listTableVIew: UITableView!
    @IBOutlet weak var randomBtn: UIButton!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let keyboardClosetap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(keyboardClosetap)
        
        listTableVIew.dataSource = self
        listTableVIew.delegate = self
        indicator.hidesWhenStopped = true
        newTextField.delegate = self
        // Observe Results Notifications
        notificationToken = personListVM.getAllPersons().observe { [weak self] (changes: RealmCollectionChange) in
            guard let tableView = self?.listTableVIew else { return }
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
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
            }
        }
        
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification: )), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(kayboardWillHide(notification: )), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    @objc func kayboardWillHide(notification: Notification) {
        bottomConstraint.constant = 20
//        self.view.frame.origin.y = 0
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {return}
        
        
//        view.frame.origin.y = -keyboardRect.height
        bottomConstraint.constant += keyboardRect.height
        
    }
    
    deinit {
        notificationToken?.invalidate()
    }
    
    @IBAction func addBtnWasPressed(_ sender: Any) {
        self.addItem()
    }
    
    
    @IBAction func randomBtnWasPressed(_ sender: Any) {
        let listArray = personListVM.getPersonsStringArray()
        if listArray.count <= 1 {
            return
        }
        randomBtn.isEnabled = false
        indicator.startAnimating()

        RandomService.instance.randomForList(listArray) { (result) in
            DispatchQueue.main.async {
                self.indicator.stopAnimating()
                self.randomBtn.isEnabled = true
            }
            switch result {
            case .success(let successArray):
//                print(successArray)
                let totalString: String = successArray.joined(separator: ", ")
                let action: UIAlertAction = UIAlertAction(title: "Next", style: .default, handler: { (action) in
                    let resultModel = ListResultModel(date: Date(), resultString: totalString)
                    self.resultViewModel = ListResultViewModel(resultModel)
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "showHistorySegue", sender: nil)
                    }
                })
                self.showAllert(title: "Result:", message: totalString, action: action)
                
            case .failure(let error):
                self.showAllert(title: "Error:", message: error.localizedDescription, action: nil)
//                fatalError(error.localizedDescription)
            }
            
            

        }
    }

    @objc func dismissKeyboard() {
        
        self.view.endEditing(true)
    }

    private func addItem() {
        if newTextField.text != "" {
            
            let personVM = PersonViewModel(newTextField.text!)
            self.personListVM.addPerson(personVM)
            newTextField.text = ""
            
            
//            self.view.endEditing(true)
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let vc = segue.destination as? ListResultViewController else {
//            fatalError("segue Error!")
            return
        }
        vc.listViewModel.addViewModel(self.resultViewModel!)
        vc.personList = self.personListVM.getPersonsStringArray()
        
    }
    
}
extension RandomListVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.addItem()
        return true
    }
}

extension RandomListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return personListVM.getAllPersonsCount()
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "listCell") else {return UITableViewCell()}
        
        let personVM = personListVM.getPerson(index: indexPath.row)
        cell.textLabel?.text = personVM.name
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.personListVM.removePerson(index: indexPath.row)
        }
    }
}
