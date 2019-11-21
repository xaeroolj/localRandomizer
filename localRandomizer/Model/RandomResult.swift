//
//  RandomResult.swift
//  localRandomizer
//
//  Created by Roman Trekhlebov on 14/09/2019.
//  Copyright © 2019 Roman Trekhlebov. All rights reserved.
//

import Foundation
import RealmSwift

class RandomResultModel: Object{
    @objc dynamic var id = 0
    @objc dynamic var resultString = ""
    @objc dynamic var generatedDate = Date()
    
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    override static func indexedProperties() -> [String] {
        return ["generatedDate"]
    }
}
