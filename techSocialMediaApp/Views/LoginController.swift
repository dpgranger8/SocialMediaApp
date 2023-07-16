//
//  ViewController.swift
//  techSocialMediaApp
//
//  Created by Brayden Lemke on 10/20/22.
//

import UIKit

class LoginController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    var shouldLogin: Bool = false
    
    var authenticationController = AuthenticationController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordTextField.isSecureTextEntry = true
        #if DEBUG
//        Uncomment the three lines below and enter your credentials to
//        automatically sign in everytime you launch the app.
        
        emailTextField.text = "DAVID.GRANGER0790@STU.MTEC.EDU"
        passwordTextField.text = "8e45ea49-284a-4930-a250-a28dc445b4d2"
        signInButtonTapped([])
        #endif
    }

    @IBAction func signInButtonTapped(_ sender: Any) {
        guard let email = emailTextField.text, !email.isEmpty,
                let password = passwordTextField.text, !password.isEmpty else {return}
        
        Task {
            do {
                // Make the API Call
                let success = try await authenticationController.signInAndAssignUser(email: email, password: password)
                if(success) {
                    goToTabController()
                }
            } catch {
                print(error)
                errorLabel.text = "Invalid Username or Password"
            }
        }
    }
    
    func goToTabController() { //example of how to push a new view controller without using navigation stack
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let tabBarController = storyboard.instantiateViewController(withIdentifier: "userSignedIn") as? MyTabBarController else {
            fatalError("Expected view controller of type MyTabBarController, but got something else.")
        }
        tabBarController.modalPresentationStyle = .fullScreen
        self.present(tabBarController, animated: true, completion: nil)
    }
    
}

