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
        
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 1,

            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                switch oldSchemaVersion {
                case 1:
                    break
                default:
                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
//                    self.zeroToOne(migration)
                    break
                }
        })
        
//        let config = Realm.Configuration()
        print(config.fileURL!)
        
        
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
    
    //List Result
    
    func getResults() -> Results<RandomResultModel> {
        let result = realm.objects(RandomResultModel.self)
        return result
    }
    
    func addResult(_ resultModel: ListResultViewModel) {
        
        let randomResult = RandomResultModel()
        randomResult.generatedDate = resultModel.date
        randomResult.resultString = resultModel.resultString
        do {
            try realm.write {
                realm.add(randomResult)
            }
            
        }catch let error as NSError {
            fatalError("Error on adding randomResult to realm \(error)")
        }
    }
    
    func removeAllResults() {
        let results = RealmService().getResults()
        
        do {
            try realm.write {
                realm.delete(results)
            }
        }catch let error as NSError {
            fatalError("Error on deleting Person from realm \(error)")
        }
        
    }
    
    
}
