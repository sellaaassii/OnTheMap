//
//  ViewController.swift
//  OnTheMap
//
//  Created by Selasi Kudolo on 2020-04-12.
//  Copyright © 2020 Ewe Cat Productions. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpTextView: UITextView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupSignupTextView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func setupSignupTextView() {
        let signupString = NSMutableAttributedString(string: "Don't have an account? Sign up")
        let signupUrl    = URL(string: "https://auth.udacity.com/sign-up")!

        signupString.setAttributes([.link: signupUrl], range: NSMakeRange(23, 7))

        signUpTextView.attributedText           = signupString
        signUpTextView.isEditable               = false
        signUpTextView.textAlignment            = .center
        signUpTextView.isUserInteractionEnabled = true

        signUpTextView.linkTextAttributes       = [.foregroundColor: UIColor.blue]
    }
    
    @IBAction func loginClicked(_ sender: Any) {
        setLoggingIn(true)
        Client.login(username: emailTextField.text ?? "", password: passwordTextField.text ?? "", completion: handleLoginResponse(success:error:))
    }
    
    func handleLoginResponse(success: Bool, error: Error?) {
        setLoggingIn(false)
        if success {
            performSegue(withIdentifier: "segueFromLogin", sender: nil)
        } else {
            print(error)
            showMessage(message: "Incorrect username or password 🌚", title: "Login Failed")
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueFromLogin" {
            self.emailTextField.text = ""
            self.emailTextField.resignFirstResponder()

            self.passwordTextField.text = ""
            self.passwordTextField.resignFirstResponder()
        }
    }
    
    func setLoggingIn(_ loggingIn: Bool) {
        if loggingIn {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
        
        loginButton.isEnabled       = !loggingIn
        emailTextField.isEnabled    = !loggingIn
        passwordTextField.isEnabled = !loggingIn
        
    }

}

