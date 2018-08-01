//
//  ProfileTableViewController.swift
//  Athena
//
//  Created by student on 27/11/2017.
//  Copyright © 2017 Sportcraft. All rights reserved.
//

import UIKit

// MARK: Profile interface for Athena

class ProfileTableViewController: UITableViewController {
    
    var cellLists: [LevelCell] = []
    var firstName: String?
    var lastName: String?
    var password: String?
    var gameDict: [GameName: Int] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboard()
        for i in 0 ..< 6 {
            cellLists.append(LevelCell(row: i))
        }
        firstName = handler.currentUser.firstName
        lastName = handler.currentUser.lastName
        gameDict = handler.currentUser.gameDict
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        firstName = handler.currentUser.firstName
        lastName = handler.currentUser.lastName
        gameDict = handler.currentUser.gameDict
        for i in LevelCell.pickers {
            cellLists[i].isHidden = true
        }
        self.tableView.reloadData()
    }
    
    @IBAction func pressSave(_ sender: Any) {
        if firstName == nil || lastName == nil {
            formIncompleteAlert(title: "Names cannot be left blank!", msg: nil)
            return
        }
        handler.currentUser.firstName = firstName!
        handler.currentUser.lastName = lastName!
        handler.currentUser.gameDict = gameDict
        if handler.currentUser.saveUser() {
            formIncompleteAlert(title: "Your profile was successfully updated!", msg: nil)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 4 : 6
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let AccountIdentifierList = ["UserIDCell","password","FirstNameCell","LastNameCell"]
            let cell = tableView.dequeueReusableCell(withIdentifier: AccountIdentifierList[indexPath.row], for: indexPath)
            switch indexPath.row {
            case 0:
                (cell as! OptionCell).valueLabel.text = handler.currentUser.email
            case 2:
                (cell as! LocationCell).locationTextField.text = self.firstName
                (cell as! LocationCell).valueChanged = { (firstName: String?) in
                    self.firstName = firstName
                }
            case 3:
                (cell as! LocationCell).locationTextField.text = self.lastName
                (cell as! LocationCell).valueChanged = { (lastName: String?) in
                    self.lastName = lastName
                }
            default:
                break
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellLists[indexPath.row].identifier, for: indexPath)
            if !LevelCell.pickers.contains(indexPath.row) {
                (cell as! OptionCell).keyLabel.text = cellLists[indexPath.row].label?.rawValue
                (cell as! OptionCell).valueLabel.text = gameDict[cellLists[indexPath.row].label!]?.description ?? "I'm not playing it"
            } else {
                (cell as! LevelPickerCell).valueChanged = {
                    (level: Int) in
                    let gameType = self.cellLists[indexPath.row - 1].label!
                    if level == 0 {
                        self.gameDict.removeValue(forKey: gameType)
                    } else {
                        self.gameDict[gameType] = level
                    }
                    self.tableView.reloadRows(at: [IndexPath(row: indexPath.row - 1, section: 1)], with: .automatic)
                }
            }
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return (section == 0) ? " Account" : " Skill Level"
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 { return 44 }
        return cellLists[indexPath.row].height
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // show/hide the pickers
        if indexPath.section == 1 && !cellLists[indexPath.row].isPicker {
            cellLists[indexPath.row + 1].toggle()
            tableView.reloadRows(at: [IndexPath(row: indexPath.row + 1, section: indexPath.section)], with: .automatic)
            for otherPickerRow in cellLists[indexPath.row + 1].getOtherPickers(){
                if !cellLists[otherPickerRow].isHidden {
                    cellLists[otherPickerRow].toggle()
                    tableView.reloadRows(at: [IndexPath(row: otherPickerRow, section: indexPath.section)], with: .automatic)
                }
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        view.tintColor = UIColor.darkGray
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        handler.lastUser = handler.currentUser
    }

}

class LevelCell {
    static var pickers = [1, 3, 5]
    var labelList = [GameName.Squash, GameName.Tennis, GameName.Badminton]
    var identifierList = ["UserIDCell","levelPicker","UserIDCell","levelPicker","UserIDCell","levelPicker"]
    
    enum heightList: CGFloat {
        case label = 44
        case picker = 125
        case hidden = 0
    }
    
    var row: Int
    var identifier: String { return identifierList[row] }
    var label: GameName?
    var isHidden: Bool
    var isPicker: Bool
    
    var height: CGFloat {
        if isHidden {
            return heightList.hidden.rawValue
        } else {
            if isPicker {
                return heightList.picker.rawValue
            } else {
                return heightList.label.rawValue
            }
        }
    }
    
    init(row: Int){
        self.row = row
        if LevelCell.pickers.contains(row) {
            self.isHidden = true
            self.isPicker = true
        } else {
            self.isHidden = false
            self.isPicker = false
        }
        self.label = labelList[row/2]
    }
    
    func toggle(){ isHidden = !isHidden }
    
    func getOtherPickers() -> [Int] {
        var otherPickers: [Int] = []
        for index in LevelCell.pickers {
            if index != self.row {
                otherPickers.append(index)
            }
        }
        return otherPickers
    }
}

class LevelPickerCell: UITableViewCell, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var picker: UIPickerView!
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    var valueChanged : ((Int) -> Void)? = nil
    
    var pickerDataSource = ["I'm not playing it", "1", "2", "3", "4", "5"]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.picker.dataSource = self
        self.picker.delegate = self
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSource.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerDataSource[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let valueChanged = self.valueChanged {
            valueChanged(row)
        }
    }
}
