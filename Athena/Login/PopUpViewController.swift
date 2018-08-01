//
//  PopUpViewController.swift
//  Athena
//
//  Created by Weijia Duan on 11/11/17.
//  Copyright © 2017 Sportcraft. All rights reserved.
//

import UIKit

// MARK: Pop up view interface for games level. Up to five level of skills provided for different games (1 - 5).
//       1 represents lowest level for the game ball, 5 represents highest level for the game ball.

class PopUpViewController: UIViewController {

    @IBOutlet weak var checkbox1: UIButton!
    
    @IBOutlet weak var checkbox2: UIButton!
    
    
    @IBOutlet weak var checkbox3: UIButton!
    
    @IBOutlet weak var checkbox4: UIButton!
    
    
    @IBOutlet weak var checkbox5: UIButton!
    
    var checkBox = UIImage(named: "checkbox")
    var uncheckBox = UIImage(named: "uncheckbox")
    
    var isboxclicked1: Bool!
    var isboxclicked2: Bool!
    var isboxclicked3: Bool!
    var isboxclicked4: Bool!
    var isboxclicked5: Bool!
    
    var gameType: GameName!
    var level: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isboxclicked1 = false
        isboxclicked2 = false
        isboxclicked3 = false
        isboxclicked4 = false
        isboxclicked5 = false
        
        self.view.backgroundColor = UIColor(white: 0, alpha: 0.6)

        self.showAnimate()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func closePopUp(_ sender: Any) {
        //self.view.removeFromSuperview()
        self.removeAnimate()
    }
    
    func showAnimate(){
        self.view.transform = CGAffineTransform(scaleX: 1.3,y: 1.3)
        self.view.alpha = 0.0
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1
            self.view.transform = CGAffineTransform(scaleX: 1.0,y: 1.0)
        });
    }
    
    func removeAnimate(){
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0;
        }, completion:{(finished:Bool) in
            if(finished){
                if self.level != 0 {
                    (self.parent as! SignUpViewController).gameDictionary[self.gameType] = self.level
                }
                self.view.removeFromSuperview()
            }
        });
    }
    
    
    @IBAction func clickbox1(_ sender: Any) {
        if isboxclicked1 == false {
            if isboxclicked2 { clickbox2(UIButton()) }
            if isboxclicked3 { clickbox3(UIButton()) }
            if isboxclicked4 { clickbox4(UIButton()) }
            if isboxclicked5 { clickbox5(UIButton()) }
            level = 1
        } else {
            level = 0
        }
        
        if isboxclicked1 == true {
            isboxclicked1 = false
        }
        else{
            isboxclicked1 = true
        }
        
        if isboxclicked1 == true {
            checkbox1.setImage(checkBox, for: UIControlState.normal)
        }
        else{
            checkbox1.setImage(uncheckBox, for: UIControlState.normal)
        }
    }
    
    @IBAction func clickbox2(_ sender: Any) {
        if isboxclicked2 == false {
            if isboxclicked1 { clickbox1(UIButton()) }
            if isboxclicked3 { clickbox3(UIButton()) }
            if isboxclicked4 { clickbox4(UIButton()) }
            if isboxclicked5 { clickbox5(UIButton()) }
            level = 2
        } else {
            level = 0
        }
        if isboxclicked2 == true {
            isboxclicked2 = false
        }
        else{
            isboxclicked2 = true
        }
        
        if isboxclicked2 == true {
            checkbox2.setImage(checkBox, for: UIControlState.normal)
        }
        else{
            checkbox2.setImage(uncheckBox, for: UIControlState.normal)
        }
    }
    
    
    @IBAction func clickbox3(_ sender: Any) {
        if isboxclicked3 == false {
            if isboxclicked2 { clickbox2(UIButton()) }
            if isboxclicked1 { clickbox1(UIButton()) }
            if isboxclicked4 { clickbox4(UIButton()) }
            if isboxclicked5 { clickbox5(UIButton()) }
            level = 3
        } else {
            level = 0
        }
        if isboxclicked3 == true {
            isboxclicked3 = false
        }
        else{
            isboxclicked3 = true
        }
        
        if isboxclicked3 == true {
            checkbox3.setImage(checkBox, for: UIControlState.normal)
        }
        else{
            checkbox3.setImage(uncheckBox, for: UIControlState.normal)
        }
    }
    
    @IBAction func clickbox4(_ sender: Any) {
        if isboxclicked4 == false {
            if isboxclicked2 { clickbox2(UIButton()) }
            if isboxclicked3 { clickbox3(UIButton()) }
            if isboxclicked1 { clickbox1(UIButton()) }
            if isboxclicked5 { clickbox5(UIButton()) }
            level = 4
        } else {
            level = 0
        }
        if isboxclicked4 == true {
            isboxclicked4 = false
        }
        else{
            isboxclicked4 = true
        }
        
        if isboxclicked4 == true {
            checkbox4.setImage(checkBox, for: UIControlState.normal)
        }
        else{
            checkbox4.setImage(uncheckBox, for: UIControlState.normal)
        }
    }
    
    @IBAction func clickbox5(_ sender: Any) {
        if isboxclicked5 == false {
            if isboxclicked2 { clickbox2(UIButton()) }
            if isboxclicked3 { clickbox3(UIButton()) }
            if isboxclicked4 { clickbox4(UIButton()) }
            if isboxclicked1 { clickbox1(UIButton()) }
            level = 5
        } else {
            level = 0
        }
        if isboxclicked5 == true {
            isboxclicked5 = false
        }
        else{
            isboxclicked5 = true
        }
        
        if isboxclicked5 == true {
            checkbox5.setImage(checkBox, for: UIControlState.normal)
        }
        else{
            checkbox5.setImage(uncheckBox, for: UIControlState.normal)
        }
    }
}
