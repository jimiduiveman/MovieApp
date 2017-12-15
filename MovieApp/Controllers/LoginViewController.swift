//
//  LoginViewController.swift
//  MovieApp
//
//  Created by Jimi Duiveman on 11-12-17.
//  Copyright © 2017 Jimi Duiveman. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
  
    let loginToApp = "loginToApp"
  
    @IBOutlet weak var textFieldLoginEmail: UITextField!
    @IBOutlet weak var textFieldLoginPassword: UITextField!
    
    @IBAction func loginTapped(_ sender: AnyObject) {
        // Sign in user
        Auth.auth().signIn(withEmail: self.textFieldLoginEmail.text!, password: self.textFieldLoginPassword.text!) { user, error in
            
            // If there is an error
            if error != nil {
                
                // Present alert with error description
                let wrongCredentials = UIAlertController(title: "Login Failed", message: error?.localizedDescription, preferredStyle: .alert)
                let tryAgain = UIAlertAction(title: "Dismiss", style: .default)
                wrongCredentials.addAction(tryAgain)
                self.present(wrongCredentials, animated: true, completion: nil)
            }
        }
    }
  
    @IBAction func signUpTapped(_ sender: AnyObject) {
        // Show alert with fill in form
        let alert = UIAlertController(title: "Register", message: "Register", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { action in
            let emailField = alert.textFields![0]
            let passwordField = alert.textFields![1]
            
            // Create user with filled in form
            Auth.auth().createUser(withEmail: emailField.text!, password: passwordField.text!) { user, error in
                
                // If succesful sign in
                if error == nil {
                    Auth.auth().signIn(withEmail: self.textFieldLoginEmail.text!, password: self.textFieldLoginPassword.text!)
                }
                else {
                    
                    // Present alert with description of error
                    let createFailure = UIAlertController(title: "Register Failed", message: error?.localizedDescription, preferredStyle: .alert)
                    let createAgain = UIAlertAction(title: "Dismiss", style: .default)
                    createFailure.addAction(createAgain)
                    self.present(createFailure, animated: true, completion: nil)
                }
            }
        }
    
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        
        alert.addTextField { textEmail in
          textEmail.placeholder = "Enter your email"
        }
        
        alert.addTextField { textPassword in
          textPassword.isSecureTextEntry = true
          textPassword.placeholder = "Enter your password"
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // If user logged in succesfully
        Auth.auth().addStateDidChangeListener() { auth, user in
            if user != nil {
                
                // Go to homescreen
                self.performSegue(withIdentifier: self.loginToApp, sender: nil)
            }
        }
        
        // Hide keyboard when tapping somewhere else on the screen
        self.hideKeyboardWhenTappedAround()
    
    }

}


// Usage of tab in app
extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == textFieldLoginEmail {
            textFieldLoginPassword.becomeFirstResponder()
        }
        if textField == textFieldLoginPassword {
            textField.resignFirstResponder()
        }
        return true
    }
  
}

// Hide keyboard when tapping somewhere else on the screen
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
