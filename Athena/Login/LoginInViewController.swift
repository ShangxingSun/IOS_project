//
//  LoginInViewController.swift
//  Athena
//
//  Created by Weijia Duan on 11/1/17.
//  Copyright © 2017 Sportcraft. All rights reserved.
//

import UIKit

// MARK: Login Interface for Athena

class LoginInViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        assignbackground()
        cancelButton.halfLoginButtonConfig()
        loginButton.halfLoginButtonConfig()
        self.hideKeyboard()
        emailTextField.placeholder = "you@example.com"
        emailTextField.text = handler.lastUser?.email
        passwordTextField.placeholder = "password"
        passwordTextField.isSecureTextEntry = true
        passwordTextField.text = handler.lastUser?.password
    }

    func assignbackground(){
        let background = UIImage(named: "background13")
        
        var imageView : UIImageView!
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIViewContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        view.addSubview(imageView)
        self.view.sendSubview(toBack: imageView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginButtonClicked(_ sender: Any) {
        if emailTextField.text?.isEmpty ?? true {
            formIncompleteAlert(title: "Please enter your registered email address", msg: nil)
            return
        }
        if passwordTextField.text?.isEmpty ?? true {
            formIncompleteAlert(title: "Please enter your password", msg: nil)
            return
        }
        handler.asyncGroup = DispatchGroup()
        let loadingView = addLoadingView()
        handler.refresh()
        handler.asyncGroup!.notify(queue: DispatchQueue.main, execute: {
            let loginStatus = handler.logIn(userEmail: self.emailTextField.text!, password: self.passwordTextField.text!)
            handler.asyncGroup = nil
            loadingView.removeFromSuperview()
            if loginStatus == 1 {
                self.formIncompleteAlert(title: "User does not exist", msg: nil)
            } else if loginStatus == 2 {
                self.formIncompleteAlert(title: "Incorret password", msg: nil)
            }
            self.performSegue(withIdentifier: "loginToHomePage", sender: nil)
        })
        
    }
    
}

// MARK: Validation for user input

extension UIViewController {
    func formIncompleteAlert(title: String, msg: String?) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        func yesHandler(actionTarget: UIAlertAction){
            print("go back to edit")
        }
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: yesHandler));
        present(alert, animated: true, completion: nil)
    }
}
