//
//  AboutVC.swift
//  localRandomizer
//
//  Created by Roman Trekhlebov on 23.12.2019.
//  Copyright © 2019 Roman Trekhlebov. All rights reserved.
//

import UIKit

class AboutVC: UIViewController {

    @IBOutlet weak var versionLbl: UILabel!
    @IBOutlet weak var appLogo: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        
        versionLbl.text = "App version: \(appVersion!), build: \(buildNumber!)"
        
        appLogo.layer.cornerRadius = 20
        appLogo.layer.masksToBounds = true

    }
    

   
}
