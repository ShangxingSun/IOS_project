//
//  ChangePasswordViewController.swift
//  Athena
//
//  Created by student on 27/11/2017.
//  Copyright © 2017 Sportcraft. All rights reserved.
//

import UIKit

// MARK: Change password interface for Profile interface

class ChangePasswordViewController: UIViewController {

    @IBOutlet weak var oldPassword: UITextField!
    @IBOutlet weak var newPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        assignbackground()
        hideKeyboard()
        oldPassword.isSecureTextEntry = true
        newPassword.isSecureTextEntry = true
    }
    
    func assignbackground(){
        let background = UIImage(named: "background8")
        var imageView : UIImageView!
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIViewContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        view.addSubview(imageView)
        self.view.sendSubview(toBack: imageView)
    }
    
    @IBAction func pressSave(_ sender: Any) {
        if oldPassword.text != handler.currentUser.password {
            formIncompleteAlert(title: "Your current password is not correct", msg: nil)
            return
        }
        if newPassword.text?.isEmpty ?? true {
            formIncompleteAlert(title: "Please enter your new password", msg: nil)
            return
        }
        handler.currentUser.password = newPassword.text!
        if handler.currentUser.saveUser() {
            formIncompleteAlert(title: "Your password was successfully reset!", msg: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
