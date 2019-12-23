//
//  PersonViewModel.swift
//  localRandomizer
//
//  Created by Roman Trekhlebov on 13/09/2019.
//  Copyright © 2019 Roman Trekhlebov. All rights reserved.
//

import Foundation
import RealmSwift

struct PersonViewModel {
    var name: String?
    
    init(_ personName: String) {
        self.name = personName
    }
}

struct PersonListViewModel
{
    
    
    func addPerson(_ personVM: PersonViewModel) {
        RealmService().addPerson(personVM.name!)
    }
    func getAllPersons() -> Results<Person> {
        return RealmService().getAllPersons()
    }
    
    func getAllPersonsCount() -> Int {
        return RealmService().getAllPersons().count
    }
    func getPerson(index: Int) -> PersonViewModel {
        let person = RealmService().getPerson(index: index)
        return PersonViewModel(person.name!)
    }
    
    func removePerson(index: Int) {
        RealmService().removePerson(index: index)
    }
    
    func getPersonsStringArray() -> [String] {
        let array: [String] = RealmService().getAllPersons().map {
            $0.name
        }
        
        return array
    }
}
