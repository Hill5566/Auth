//
//  ViewController.swift
//  Auth
//
//  Created by Lin Hill on 2022/12/7.
//

import UIKit
import FacebookLogin
import LineSDK
import GoogleSignIn

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        fbLogin()
        lineLogin()
    }
    
    func fbLogin() {
        
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
    
    func lineLogin() {
        // Create Login Button.
        let loginButton = LoginButton()
        loginButton.delegate = self
        
        // Configuration for permissions and presenting.
        loginButton.permissions = [.profile]
        loginButton.presentingViewController = self
        
        // Add button to view and layout it.
        view.addSubview(loginButton)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50).isActive = true
    }
    
    @IBAction func signIn(sender: UIButton) {
        let signInConfig = GIDConfiguration(clientID: "745768429617-n5cojnr730qore0l41hhh3s7pol4b2oc.apps.googleusercontent.com")
        
        GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: self) { user, error in
            guard error == nil else { return }
            print(user?.profile?.name)
            print(user?.profile?.email)
        }
    }
    @IBAction func signOut(sender: UIButton) {
      GIDSignIn.sharedInstance.signOut()
    }
}

extension ViewController: LineSDK.LoginButtonDelegate {
    
    func loginButton(_ button: LoginButton, didSucceedLogin loginResult: LineSDK.LoginResult) {
        print(loginResult)
//        UIAlertController.present(in: self, successResult: "\(loginResult)") {
//            NotificationCenter.default.post(name: .userDidLogin, object: loginResult)
//        }
    }
    
    func loginButton(_ button: LoginButton, didFailLogin error: LineSDKError) {
        #if targetEnvironment(macCatalyst)
        // For macCatalyst app, we allow process discarding so just ignore this error.
        if case .generalError(reason: .processDiscarded(let p)) = error {
            print("Process discarded: \(p)")
            return
        }
        #endif
        
//        UIAlertController.present(in: self, error: error)
    }
    
    func loginButtonDidStartLogin(_ button: LoginButton) {
        #if !targetEnvironment(macCatalyst)
        #endif
    }
    
}
