//
//  ViewController.swift
//  Athena
//
//  Created by student on 01/11/2017.
//  Copyright © 2017 Sportcraft. All rights reserved.
//

import UIKit

// MARK: Entry page interface for Athena. Two functions provided Login and Sign Up

class EntryPageController: UIViewController {

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        assignbackground()
        loginButton.loginButtonConfig()
        signUpButton.loginButtonConfig()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func assignbackground(){
        let background = UIImage(named: "background11")
        
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
   
    @IBAction func returnToEntryPage(segue: UIStoryboardSegue) {}

}

