//
//  SignUpViewController.swift
//  Athena
//
//  Created by Weijia Duan on 11/1/17.
//  Copyright © 2017 Sportcraft. All rights reserved.
//

import UIKit

// MARK: Sign Up interface for Athena

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var firstnameTextField: UITextField!
    @IBOutlet weak var lastnameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    var gameDictionary: [GameName:Int] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        assignbackground()
        self.hideKeyboard()
        passwordTextField.isSecureTextEntry = true
        cancelButton.halfLoginButtonConfig()
        signupButton.halfLoginButtonConfig()
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
    

    @IBAction func showSquashPopUp(_ sender: Any) {
        let popOverVC = UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "sbPopUpID") as! PopUpViewController
        self.addChildViewController(popOverVC)
        popOverVC.view.frame = self.view.frame
        popOverVC.gameType = .Squash
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParentViewController: self)
      
    }
    
    
    @IBAction func showTennisPopUp(_ sender: Any) {
        let popOverVC = UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "sbPopUpID") as! PopUpViewController
        self.addChildViewController(popOverVC)
        popOverVC.view.frame = self.view.frame
        popOverVC.gameType = .Tennis
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParentViewController: self)
    }
    
    @IBAction func showBadmintonPopUp(_ sender: Any) {
        let popOverVC = UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "sbPopUpID") as! PopUpViewController
        self.addChildViewController(popOverVC)
        popOverVC.view.frame = self.view.frame
        popOverVC.gameType = .Badminton
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParentViewController: self)
    }
    
    // MARK: Navigation
    
    @IBAction func pressSignup(_ sender: Any) {
        if (firstnameTextField.text?.isEmpty ?? true) || (lastnameTextField.text?.isEmpty ?? true) || (emailTextField.text?.isEmpty ?? true) ||
            (passwordTextField.text?.isEmpty ?? true) {
            formIncompleteAlert(title: "Not completed yet!", msg: "All fields are required")
            return
        }
        if gameDictionary.isEmpty {
            formIncompleteAlert(title: "Please register at least one game", msg: "Otherwise you will not be able to join a game")
            return
        }
        let newUser = User(firstName: firstnameTextField.text!, lastName: lastnameTextField.text!, email: emailTextField.text!, password: passwordTextField.text!, myGame: [], gameDict: gameDictionary)
        if !handler.signUp(newUser: newUser){
            formIncompleteAlert(title: "Fail to register", msg: "Please try again later")
            return
        }
        handler.asyncGroup = DispatchGroup()
        let loadingView = addLoadingView()
        handler.refresh()
        handler.asyncGroup!.notify(queue: DispatchQueue.main, execute: {
            handler.asyncGroup = nil
            loadingView.removeFromSuperview()
            self.performSegue(withIdentifier: "signupToHomePage", sender: nil)
        })
 
    }

}
