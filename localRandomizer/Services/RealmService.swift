//
//  RealmService.swift
//  localRandomizer
//
//  Created by Roman Trekhlebov on 13/09/2019.
//  Copyright © 2019 Roman Trekhlebov. All rights reserved.
//

import Foundation
import RealmSwift

class RealmService {
    
    var realm: Realm {
        let config = Realm.Configuration()
        Realm.Configuration.defaultConfiguration = config
        do {
            let realm = try Realm()
            return realm
        } catch let error as NSError {
            fatalError("Error using realm: \(error)")
        }
        
        
    }
    
    func addPerson(_ name: String) {
        
        let person = Person()
        person.name = name
        do {
            try realm.write {
                realm.add(person)
            }
            
        }catch let error as NSError {
            fatalError("Error on adding Person to realm \(error)")
        }
        
        
        
    }
    func removePerson(index: Int) {
        let persons = RealmService().getAllPersons()
        let person = persons[index]
        do {
            try realm.write {
                realm.delete(person)
            }
        }catch let error as NSError {
            fatalError("Error on deleting Person from realm \(error)")
        }
        
    }
    
    func getPerson(index: Int) -> PersonViewModel{
        let name = RealmService().getAllPersons()[index].name
        
        let personVM = PersonViewModel(name)
        return personVM
        
        
    }
    
    func getAllPersons() -> Results<Person> {
        let result = realm.objects(Person.self)
        return result
    }
    
}
