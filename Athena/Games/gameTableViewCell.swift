//
//  gameTableViewCell.swift
//  Athena
//
//  Created by Ellie Zheng on 11/19/2017.
//  Copyright © 2017 Sportcraft. All rights reserved.
//

import UIKit

class gameTableViewCell: UITableViewCell {

    @IBOutlet weak var Duration: UILabel!
    @IBOutlet weak var Host: UILabel!
    @IBOutlet weak var Player: UILabel!
    @IBOutlet weak var Difficulty: UILabel!
    @IBOutlet weak var Time: UILabel!
    @IBOutlet weak var Location: UILabel!
    @IBOutlet weak var joinGame: JoinGameButton!
    @IBOutlet weak var gameImg: UIImageView!
    
    @IBAction func buttonClicked(_ sender: Any) {
        switch joinGame.type {
        case .edit:
            if let editButtonTapped = self.editButtonTapped {
                editButtonTapped()
            }
        case .quit:
            if let quitButtonTapped = self.quitButtonTapped {
                quitButtonTapped()
            }
        case .available:
            if let joinButtonTapped = self.joinButtonTapped {
                joinButtonTapped()
            }
        default:
            break
        }
    }
    
    var editButtonTapped : (() -> Void)? = nil
    var quitButtonTapped : (() -> Void)? = nil
    var joinButtonTapped : (() -> Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        // Configure the view for the selected state
        super.setSelected(selected, animated: animated)
    }
    
}
