//
//  ViewController.swift
//  BSDevLibsExamples
//
//  Created by Bhavesh Sarwar on 26/02/20.
//  Copyright © 2020 Bhavesh Sarwar. All rights reserved.
//

import UIKit
import BSDevLibs

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        BSDLNetworkManager.shared.sendRequest(methodType: .post, apiName: "http://vps3.inspeero.com:3003/api/users/login", parameters: ["email":"pranaydj@gmail.com","password":"Qwerty123"], headers: nil) { (response, error) in

            print("Response received")
            
        }
        // Do any additional setup after loading the view.
    }


}

