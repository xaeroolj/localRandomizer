//
//  ListResultViewModel.swift
//  localRandomizer
//
//  Created by Roman Trekhlebov on 14/09/2019.
//  Copyright © 2019 Roman Trekhlebov. All rights reserved.
//

import Foundation
import RealmSwift

struct ListResultViewModel {
    let date: Date
    let resultString: String
    
    init(_ model: ListResultModel) {
        self.date = model.date!
        self.resultString = model.resultString!
        
    }
    func storeValues() {
        RealmService().addResult(self)
    }
    
    func returnDateString() -> String {
        let formatter = DateFormatter()
        // initially set the format based on your datepicker date / server String
        formatter.dateFormat = "dd/MM/yyyy HH:mm:ss "
        //        07/16/20 02:07 AM
        let myString = formatter.string(from: self.date)
        
        return myString
    }
}

struct ListResultTotalViewModel {
//    private var resultArray = [ListResultViewModel]()
    
    mutating func addViewModel(_ viewModel: ListResultViewModel) {
//        self.resultArray.append(viewModel)
        viewModel.storeValues()
    }
    
    func viewModelFor(index: Int) -> ListResultViewModel{
        let realmItem = self.getAllResults()[index]
        
        let model = ListResultModel(date: realmItem.generatedDate, resultString: realmItem.resultString)
        let returnItemVM = ListResultViewModel(model)
        return returnItemVM
    }
    func totalItems() -> Int {
        return self.getAllResults().count
    }
    
    func getAllResults() -> Results<RandomResultModel> {
        return RealmService().getResults()
    }
    
    mutating func fillStroredResults() {
        
        let results = RealmService().getResults()
        var resultArray = [ListResultViewModel]()
        results.forEach { (result) in
            let listRM = ListResultModel(date: result.generatedDate, resultString: result.resultString)
            let resultVM = ListResultViewModel(listRM)
            resultArray.append(resultVM)
        }
//        self.resultArray = resultArray
//        return resultArray
        
    }
}

