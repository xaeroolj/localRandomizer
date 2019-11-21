//
//  ListResultViewModel.swift
//  localRandomizer
//
//  Created by Roman Trekhlebov on 14/09/2019.
//  Copyright © 2019 Roman Trekhlebov. All rights reserved.
//

import Foundation

struct ListResultViewModel {
    let date: Date
    let resultString: String
    
    init(_ model: ListResultModel) {
        self.date = model.date!
        self.resultString = model.resultString!
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
    private var resultArray = [ListResultViewModel]()
    
    mutating func addViewModel(_ viewModel: ListResultViewModel) {
        self.resultArray.append(viewModel)
    }
    
    func viewModelFor(index: Int) -> ListResultViewModel{
        return self.resultArray[index]
    }
    func totalItems() -> Int {
        return self.resultArray.count
    }
}

