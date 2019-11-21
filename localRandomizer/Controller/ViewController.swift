//
//  ViewController.swift
//  localRandomizer
//
//  Created by Roman Trekhlebov on 08.04.2018.
//  Copyright © 2018 Roman Trekhlebov. All rights reserved.
//

import UIKit

class ViewController: UIViewController, RandomServiceDelegate {
    
    
    
    //Vars
    
    let ptpService = PTPService()
    
    //Outlets
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var testLbl: UILabel!
    
    @IBAction func clearBtnPressed(_ sender: Any) {
        textView.text = "" 
    }
    
    @IBAction func generatePressed(_ sender: Any) {
        
        self.randomFunc()
        
    }
//    @IBAction func redTapped() {
//        self.change(color: .red)
//        ptpService.send(colorName: "red")
//    }
//
//    @IBAction func yellowTapped() {
//        self.change(color: .yellow)
//        ptpService.send(colorName: "yellow")
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ptpService.delegate = self
        RandomService.instance.delegate = self
        
        //Temp
        RandomService.instance.randomForList(["Smirnov", "Moskalev", "Trekhlebov", "Kolupaeva"]) { (result) in
            print(result)
        }
        
        
    }
    
    func serviceResult(result: String) {
        textView.text.append("\(result)\n")
        ptpService.sendRandom(randomString: result)
    }

    func randomFunc() {
        
        RandomService.instance.getRandom()
    }

    func change(color : UIColor) {
        UIView.animate(withDuration: 0.2) {
            self.view.backgroundColor = color
        }
    }

}
extension ViewController : PTPManagerDelegate {
    func dataRecived(manager: PTPService, dataString: String) {
        DispatchQueue.main.async {
            self.textView.text.append("\(dataString)\n")
        }
        
    }
    
    
    func connectedDevicesChanged(manager: PTPService, connectedDevices: [String]) {
        OperationQueue.main.addOperation {
            self.testLbl.text = "Connections: \(connectedDevices)"
        }
    }
    
    func colorChanged(manager: PTPService, colorString: String) {
        OperationQueue.main.addOperation {
            switch colorString {
            case "red":
                self.change(color: .red)
            case "yellow":
                self.change(color: .yellow)
            default:
                NSLog("%@", "Unknown color value received: \(colorString)")
            }
        }
    }
    
}

