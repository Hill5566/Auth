//
//  ViewController.swift
//  auth_samples
//
//  Created by Lin Hill on 2022/12/10.
//

import UIKit
import FacebookLogin
import LineSDK
import AuthenticationServices
import GoogleSignIn

class ViewController: UIViewController {
    
    @IBOutlet weak var loginProviderStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupProviderLoginView()
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
    
    /// - Tag: add_appleid_button
    func setupProviderLoginView() {
        let authorizationButton = ASAuthorizationAppleIDButton()
        authorizationButton.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
        self.loginProviderStackView.addArrangedSubview(authorizationButton)
    }
    
    // - Tag: perform_appleid_password_request
    /// Prompts the user if an existing iCloud Keychain credential or Apple ID credential is found.
    func performExistingAccountSetupFlows() {
        // Prepare requests for both Apple ID and password providers.
        let requests = [ASAuthorizationAppleIDProvider().createRequest(),
                        ASAuthorizationPasswordProvider().createRequest()]
        
        // Create an authorization controller with the given requests.
        let authorizationController = ASAuthorizationController(authorizationRequests: requests)
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    /// - Tag: perform_appleid_request
    @objc
    func handleAuthorizationAppleIDButtonPress() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
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

extension ViewController: ASAuthorizationControllerDelegate {
    /// - Tag: did_complete_authorization
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            
            // Create an account in your system.
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            
            // For the purpose of this demo app, store the `userIdentifier` in the keychain.
            self.saveUserInKeychain(userIdentifier)
            
            // For the purpose of this demo app, show the Apple ID credential information in the `ResultViewController`.
            self.showResultViewController(userIdentifier: userIdentifier, fullName: fullName, email: email)
            
        case let passwordCredential as ASPasswordCredential:
            
            // Sign in using an existing iCloud Keychain credential.
            let username = passwordCredential.user
            let password = passwordCredential.password
            
            // For the purpose of this demo app, show the password credential as an alert.
            DispatchQueue.main.async {
                self.showPasswordCredentialAlert(username: username, password: password)
            }
            
        default:
            break
        }
    }
    
    private func saveUserInKeychain(_ userIdentifier: String) {
        do {
            try KeychainItem(service: "com.hilllin.authsamples", account: "userIdentifier").saveItem(userIdentifier)
        } catch {
            print("Unable to save userIdentifier to keychain.")
        }
    }
    
    private func showResultViewController(userIdentifier: String, fullName: PersonNameComponents?, email: String?) {
        
        print(userIdentifier, fullName, email)
        //        guard let viewController = self.presentingViewController as? ResultViewController
        //            else { return }
        //
        //        DispatchQueue.main.async {
        //            viewController.userIdentifierLabel.text = userIdentifier
        //            if let givenName = fullName?.givenName {
        //                viewController.givenNameLabel.text = givenName
        //            }
        //            if let familyName = fullName?.familyName {
        //                viewController.familyNameLabel.text = familyName
        //            }
        //            if let email = email {
        //                viewController.emailLabel.text = email
        //            }
        //            self.dismiss(animated: true, completion: nil)
        //        }
    }
    
    private func showPasswordCredentialAlert(username: String, password: String) {
        let message = "The app has received your selected credential from the keychain. \n\n Username: \(username)\n Password: \(password)"
        let alertController = UIAlertController(title: "Keychain Credential Received",
                                                message: message,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    /// - Tag: did_complete_error
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
    }
}

extension ViewController: ASAuthorizationControllerPresentationContextProviding {
    /// - Tag: provide_presentation_anchor
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}


extension UIViewController {
    
    func showLoginViewController() {
        //        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        //        if let loginViewController = storyboard.instantiateViewController(withIdentifier: "loginViewController") as? LoginViewController {
        //            loginViewController.modalPresentationStyle = .formSheet
        //            loginViewController.isModalInPresentation = true
        //            self.present(loginViewController, animated: true, completion: nil)
        //        }
    }
}

// Google sign in
extension UIViewController {
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
