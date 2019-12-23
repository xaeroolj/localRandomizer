//
//  RandomService.swift
//  localRandomizer
//
//  Created by Roman Trekhlebov on 08.04.2018.
//  Copyright © 2018 Roman Trekhlebov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

//Content-Type = application/json-rpc
/*
{"jsonrpc":"2.0",
 "method":"generateIntegers",
 "params":
        {
            "apiKey":"00000000-0000-0000-0000-000000000000",
            "n":10,
            "min":1,
            "max":10,
            "replacement":false,
            "base":10
        },
 "id":23399}
 */

//let headers: HTTPHeaders = [
//    "Authorization": "Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ==",
//    "Accept": "application/json"
//]
//let parameters: Parameters = [
//    "foo": "bar",
//    "baz": ["a", 1],
//    "qux": [
//        "x": 1,
//        "y": 2,
//        "z": 3
//    ]
//]


class RandomService {
    
    static let instance =  RandomService()
    var delegate: RandomServiceDelegate?
    var resultArray: [Int] = [Int]()
    
    var lastNames = [String]()
    let nameDic: [Int : String] = [1 : "123",
                                   2 : "12345",
                                   3 : "1234567",
                                   4 : "1234567890"]
    func generateString() -> String {
        
        var stringArray = [String]()
        for item in resultArray {
            stringArray.append(nameDic[item]!)
        }
        
        
        
        return "\(stringArray)"
    }
    
    func getRandom() {
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        
        let parameters: Parameters = [
            "jsonrpc":"2.0",
            "method":"generateIntegers",
            "params":["apiKey":"\(APIKEY)",
            "n":4,
            "min":1,
            "max":4,
            "replacement":false,
            "base":10
            ],
            "id": 23399]
        
        
        Alamofire.request("https://api.random.org/json-rpc/2/invoke", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            debugPrint(response)
            
            if let json = response.result.value {
                let swiftyJson = JSON(json)
                let result = swiftyJson["result"]["random"]["data"]
                self.resultArray.removeAll()
                for item in result {
                    self.resultArray.append(item.1.int!)
                }
                let resultString = self.generateString()
                self.delegate?.serviceResult(result: resultString)
            }
        }
        
    }
    
    func randomForList(_ names: [String], completion: @escaping (Swift.Result<[String], Error>) -> ()) {
        let urlString = "https://api.random.org/json-rpc/2/invoke"
        guard let url = URL(string: urlString) else {return}
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.allHTTPHeaderFields = ["Content-Type": "application/json"]
        
        let json: [String: Any] = [
        "jsonrpc":"2.0",
        "method":"generateIntegers",
        "params":["apiKey":"\(APIKEY)",
        "n":names.count,
        "min":1,
        "max":names.count,
        "replacement":false,
        "base":10
        ],
        "id": 23399]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        urlRequest.httpBody = jsonData
        
        URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            let dataString = String(NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!)
//            print(dataString)
            do {
                let resultList = try JSONDecoder().decode(ListResult.self, from: data!)
                var nameResultArray = [String]()
                resultList.result.random.data.forEach { index in
                    nameResultArray.append(names[index-1])
                }
                
            
                completion(.success(nameResultArray))
            } catch let jsonError {
                completion(.failure(jsonError))
            }
        }.resume()
    }
}
protocol RandomServiceDelegate {
    func serviceResult(result: String)
    
}

struct ListResult: Codable {
    let jsonrpc: String
    let result: RandomResult
    let id: Int
}

struct RandomResult: Codable {
    let random: RandomResultRandom
    let bitsUsed, bitsLeft, requestsLeft, advisoryDelay: Int
}

struct RandomResultRandom: Codable {
    let data: [Int]
    let completionTime: String
}

