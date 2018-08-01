//
//  Design.swift
//  Athena
//
//  Created by Ellie Zheng on 11/19/2017.
//  Copyright © 2017 Sportcraft. All rights reserved.
//

import UIKit

// MARK: Ball game design and implementation.

let ballImage: [GameName: UIImage] = [.Squash: #imageLiteral(resourceName: "black-squash"), .Badminton: #imageLiteral(resourceName: "black-badminton"), .Tennis: #imageLiteral(resourceName: "black-tennis")]
extension UITableViewController {
    override open func viewWillAppear(_ animated: Bool) {
        // Add a background view to the table view
        let backgroundImage = UIImage(named: "background8")
        let imageView = UIImageView(image: backgroundImage)
        self.tableView.backgroundView = imageView
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
}

extension UITableViewCell {    
    override open func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor(white: 1.3, alpha: 0.55)
    }
}

class styles {
    static let lightblue = UIColor(red: 40/255.0, green: 110/255.0, blue: 220/255.0, alpha: 0.8)
    static let orange = UIColor(red: 220/255.0, green: 110/255.0, blue: 40/255.0, alpha: 0.8)
    static let valet = UIColor(red: 150/255.0, green: 30/255.0, blue: 120/255.0, alpha: 0.5)
    static let darkred = UIColor(red: 180/255.0, green: 20/255.0, blue: 20/255.0, alpha: 0.8)
    static let white = UIColor.white
    static let VerdanaBold = UIFont(name: "Verdana-Bold", size: 16) ?? UIFont.systemFont(ofSize: 16)
    static let Verdana = UIFont(name: "Verdana", size: 16) ?? UIFont.systemFont(ofSize: 16)
}

extension UIButton {
    func loginButtonConfig(){
        center.x = self.superview!.center.x
        halfLoginButtonConfig()
    }
    func halfLoginButtonConfig(){
        layer.borderWidth = 1
        layer.borderColor = styles.white.cgColor
        layer.cornerRadius = 2
        contentEdgeInsets = UIEdgeInsetsMake(2, 2, 2, 2)
        showsTouchWhenHighlighted = true
        backgroundColor = UIColor(white: 0, alpha: 0.4)
    }
}

class JoinGameButton: UIButton {
    enum ButtonType {
        case available, filled, joined, edit, quit
    }
    var type: ButtonType = .available
    func commonStyle() {
        isHidden = false
        titleLabel?.font = styles.Verdana
        layer.borderWidth = 1
        layer.borderColor = styles.lightblue.cgColor
        layer.cornerRadius = 2
        contentEdgeInsets = UIEdgeInsetsMake(2, 2, 2, 2)
        showsTouchWhenHighlighted = true
    }
    func available() {
        commonStyle()
        setTitle("Join", for: .normal)
        backgroundColor = styles.lightblue
        setTitleColor(styles.white, for: .normal)
        type = .available
    }
    func filled() {
        commonStyle()
        setTitle("Filled", for: .normal)
        backgroundColor = UIColor.clear
        setTitleColor(styles.lightblue, for: .normal)
        type = .filled
    }
    func joined() {
        commonStyle()
        setTitle("Joined", for: .normal)
        backgroundColor = UIColor.clear
        setTitleColor(styles.lightblue, for: .normal)
        type = .joined
    }
    func edit(){
        commonStyle()
        setTitle("Edit", for: .normal)
        backgroundColor = styles.lightblue
        setTitleColor(styles.white, for: .normal)
        type = .edit
    }
    func quit(){
        commonStyle()
        layer.borderColor = styles.darkred.cgColor
        setTitle("Quit", for: .normal)
        backgroundColor = styles.darkred
        setTitleColor(styles.white, for: .normal)
        type = .quit
    }
}

extension UIImage {
    static func fromColor(_ color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}

// Tab bar icon credits:
// archive by IconMark from the Noun Project
// people by alvianwijaya from the Noun Project
// Home by Maxim Kulikov from the Noun Project
// Tennis Ball by jhonnytornado66 from the Noun Project
