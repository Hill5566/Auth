//
//  ViewController.swift
//  Auth
//
//  Created by Lin Hill on 2022/12/7.
//

import UIKit
import FacebookLogin


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let loginButton = FBLoginButton()
        loginButton.center = view.center
        view.addSubview(loginButton)
        
        if let token = AccessToken.current,
                !token.isExpired {
                // User is logged in, do work such as go to next view controller.
            }
        
        
        // Extend the code sample from 6a. Add Facebook Login to Your Code
        // Add to your viewDidLoad method:
        loginButton.permissions = ["public_profile", "email"]
          
    }
    @IBAction func request(_ sender: UIButton) {
        
        if AccessToken.current != nil {
            GraphRequest(graphPath: "me").start { connection, result, error in
                if let result = result {
                    print("Fetched Result: \(result)")
                }
            }
        }
        
    }
    
}

