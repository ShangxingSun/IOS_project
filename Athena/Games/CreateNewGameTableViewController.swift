//
//  CreateNewGameTableViewController.swift
//  Athena
//
//  Created by Ellie Zheng on 11/20/2017.
//  Copyright © 2017 Sportcraft. All rights reserved.
//

import UIKit

// MARK: Add new game interface for Athena.
// Source reference - https://stackoverflow.com/questions/29678471/expanding-and-collapsing-uitableviewcells-with-datepicker

class CreateNewGameTableViewController: UITableViewController {
    
    var cellLists: [CreateGameCell] = []
    var date: NSDate?
    var startTime: NSDate?
    var endTime: NSDate?
    var location: String?
    var gameType: GameName?
    var level: Int?
    
    var gameToBeEdit: Game?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for i in 0 ... 9 {
            cellLists.append(CreateGameCell(row: i))
        }
        if let existingGame = gameToBeEdit {
            date = existingGame.startTime
            startTime = existingGame.startTime
            endTime = existingGame.endTime
            location = existingGame.location
            gameType = existingGame.gameName
            level = existingGame.level
            cellLists[9].isHidden = false
            self.navigationController?.setToolbarHidden(false, animated: true)
        } else {
            if gameType != nil {
                cellLists[9].isHidden = false
                level = handler.currentUser.gameDict[gameType!]
            }
        }
        hideKeyboard()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        self.navigationController?.setToolbarHidden(true, animated: animated)
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellLists.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellLists[indexPath.row].identifier, for: indexPath)
        cellLists[indexPath.row].configCell(VC: self, cell: cell)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellLists[indexPath.row].height
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // show/hide the pickers
        if cellLists[indexPath.row].hasPicker {
            cellLists[indexPath.row + 1].toggle()
            tableView.reloadRows(at: [IndexPath(row: indexPath.row + 1, section: indexPath.section)], with: .automatic)
            //tableView.reloadRows(at: [IndexPath(row: indexPath.row, section: indexPath.section)], with: .automatic)
        }
        // collapse all other pickers
        if !cellLists[indexPath.row].isPicker {
            for otherPickerRow in cellLists[min(indexPath.row + 1, cellLists.count - 1)].getOtherPickers(){
                if !cellLists[otherPickerRow].isHidden {
                    cellLists[otherPickerRow].toggle()
                    tableView.reloadRows(at: [IndexPath(row: otherPickerRow, section: indexPath.section)], with: .automatic)
                }
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Actions and Segues
    
    @IBAction func deleteButtonClicked(_ sender: Any) {
        let alert = UIAlertController(title: "Are you sure to delete this game?", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.cancel, handler: nil))
        //event handler with closure
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: {(action: UIAlertAction) in
            if handler.deleteExistingGame(game: self.gameToBeEdit!) {
                print("Game deleted.")
            }
            self.performSegue(withIdentifier: "returnToUpcomingGame", sender: nil)
        }))
        present(alert, animated: true, completion: nil)
    }

    @IBAction func pressSave(_ sender: Any) {
        if self.date == nil || self.startTime == nil || self.endTime == nil || self.location == nil || self.location == "" || self.gameType == nil {
            formIncompleteAlert(title: "Not completed yet!", msg: "All fields are required")
            return
        }
        if self.level == nil {
            formIncompleteAlert(title: "Your \(self.gameType!.rawValue) information not found", msg: "please update your profile first")
            return
        }
        let startTime = self.startTime!
        let endTime = self.endTime!
        let startDate = NSDate.combineDateWithTime(date: date!, time: startTime)! as NSDate
        let endDate = NSDate.combineDateWithTime(date: date!, time: endTime)! as NSDate
        if !startDate.isLessThanDate(dateToCompare: endDate) {
            formIncompleteAlert(title: "Game time not valid", msg: "game ending time must be later than its starting time")
            return
        }
        if gameToBeEdit == nil {
            let newGame = Game(gameName: gameType!, location: location!, startTime: startDate, endTime: endDate, owner: handler.currentUser.getKey(), player:[], level: level!, maxPlayer: 2)
            if handler.addNewGame(game: newGame){
                print("Game added.")
            }
        } else {
            let newVersion = Game(gameName: gameType!, location: location!, startTime: startDate, endTime: endDate, owner: gameToBeEdit!.owner, player: gameToBeEdit!.player, level: level!, maxPlayer: gameToBeEdit!.maxPlayer)
            if handler.editOwnGame(gameID: gameToBeEdit!.gameID, newVersion: newVersion){
                print("Game edited.")
            }
        }
        performSegue(withIdentifier: "returnToUpcomingGame", sender: nil)
    }
    
    //https://stackoverflow.com/questions/30276503/where-to-find-a-clear-explanation-about-swift-alert-uialertcontroller
    func formIncompleteAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        func yesHandler(actionTarget: UIAlertAction){
            print("go back to edit")
        }
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: yesHandler));
        present(alert, animated: true, completion: nil)
    }
}

class CreateGameCell {
    static var pickers = [1, 3, 5, 8]
    var labelList = ["Date", "", "Start at", "", "End at", "", "Location", "Game Type", "", "Level"]
    var identifierList = ["optionCell","datePicker","optionCell","timePicker","optionCell","timePicker","locationCell","optionCell","gameTypePicker","optionCell"]
    enum heightList: CGFloat {
        case label = 44
        case picker = 125
        case hidden = 0
    }
    
    var row: Int
    var identifier: String = ""
    var label: String?
    var defaultValue: String = ">"
    var isHidden: Bool
    var hasPicker: Bool
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
        self.identifier = self.identifierList[row]
        if CreateGameCell.pickers.contains(row) {
            self.isHidden = true
            self.isPicker = true
            self.hasPicker = false
        } else {
            self.isHidden = (row == 9) ? true : false
            self.isPicker = false
            self.hasPicker = ([0, 2, 4, 7].contains(row)) ? true : false
            self.label = labelList[row]
        }
    }
    
    func toggle(){ isHidden = !isHidden }
    
    func getOtherPickers() -> [Int] {
        var otherPickers: [Int] = []
        for index in CreateGameCell.pickers {
            if index != self.row {
                otherPickers.append(index)
            }
        }
        return otherPickers
    }
    
    func configCell(VC: CreateNewGameTableViewController, cell: UITableViewCell) {
        switch self.row {
        case 0:
            (cell as! OptionCell).keyLabel.text = self.label
            (cell as! OptionCell).valueLabel.text = VC.date?.formatedDate ?? self.defaultValue
        case 1:
            (cell as! DatePickerCell).valueChanged = { (date: NSDate) in
                VC.date = date
                VC.tableView.reloadRows(at: [IndexPath(row: self.row - 1, section: 0)], with: .none)
            }
        case 2:
            (cell as! OptionCell).keyLabel.text = self.label
            (cell as! OptionCell).valueLabel.text = VC.startTime?.formatedTimeOnly ?? self.defaultValue
        case 3:
            (cell as! TimePickerCell).valueChanged = { (time: NSDate) in
                VC.startTime = time
                VC.tableView.reloadRows(at: [IndexPath(row: self.row - 1, section: 0)], with: .none)
            }
        case 4:
            (cell as! OptionCell).keyLabel.text = self.label
            (cell as! OptionCell).valueLabel.text = VC.endTime?.formatedTimeOnly ?? self.defaultValue
        case 5:
            (cell as! TimePickerCell).valueChanged = { (time: NSDate) in
                VC.endTime = time
                VC.tableView.reloadRows(at: [IndexPath(row: self.row - 1, section: 0)], with: .none)
            }
        case 6:
            (cell as! LocationCell).locationTextField.text = VC.location
            (cell as! LocationCell).valueChanged = { (location: String?) in
                VC.location = location
            }
        case 7:
            (cell as! OptionCell).keyLabel.text = self.label
            if let gameType = VC.gameType {
                (cell as! OptionCell).valueLabel.text = gameType.rawValue
            } else {
                (cell as! OptionCell).valueLabel.text = self.defaultValue
                //(cell as! OptionCell).valueLabel.text = VC.cellLists[8].isHidden ? self.defaultValue : GameName.Squash.rawValue
            }
        case 8:
            (cell as! GamePickerCell).valueChanged = { (gameType: GameName) in
                VC.gameType = gameType
                VC.level = handler.currentUser.gameDict[gameType]
                VC.tableView.reloadRows(at: [IndexPath(row: self.row - 1, section: 0)], with: .none)
                if VC.cellLists[9].isHidden {
                    VC.cellLists[9].toggle()
                    VC.tableView.reloadRows(at: [IndexPath(row: 9, section: 0)], with: .automatic)
                } else {
                    VC.tableView.reloadRows(at: [IndexPath(row: 9, section: 0)], with: .none)
                }
            }
        case 9:
            (cell as! OptionCell).keyLabel.text = self.label
            (cell as! OptionCell).valueLabel.text = VC.level?.description ?? "not set in profile"
        default:
            break
        }
    }
}

class OptionCell: UITableViewCell {
    @IBOutlet weak var keyLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
}

class DatePickerCell: UITableViewCell {
    @IBOutlet weak var datePicker: UIDatePicker!
    var valueChanged : ((NSDate) -> Void)? = nil
    override func awakeFromNib() {
        super.awakeFromNib()
        // set the minimum date to tomorrow
        let gregorian: NSCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        let currentDate = Date()
        let components = NSDateComponents()
        components.day = 1
        let minDate = gregorian.date(byAdding: components as DateComponents, to: currentDate, options: NSCalendar.Options(rawValue: 0))!
        datePicker.minimumDate = minDate
    }
    @IBAction func datePickerAction(_ sender: Any) {
        if let valueChanged = self.valueChanged {
            valueChanged(datePicker.date as NSDate)
        }
    }
}

class TimePickerCell: UITableViewCell{
    @IBOutlet weak var timePicker: UIDatePicker!
    var valueChanged : ((NSDate) -> Void)? = nil

    @IBAction func timePickerAction(_ sender: Any) {
        if let valueChanged = self.valueChanged {
            valueChanged(timePicker.date as NSDate)
        }
    }
}

class GamePickerCell: UITableViewCell, UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    var valueChanged : ((GameName) -> Void)? = nil
    @IBOutlet weak var gamePicker: UIPickerView!
    var pickerDataSource = [GameName.Squash, GameName.Squash, GameName.Tennis, GameName.Badminton]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.gamePicker.dataSource = self
        self.gamePicker.delegate = self
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSource.count;
    }
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return (row == 0) ?
            NSAttributedString(string: "Please select", attributes: [NSAttributedStringKey.foregroundColor:UIColor.gray])
            : NSAttributedString(string: pickerDataSource[row].rawValue, attributes: [NSAttributedStringKey.foregroundColor:UIColor.darkText])
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //https://stackoverflow.com/questions/30105189/how-to-add-a-button-with-click-event-on-uitableviewcell-in-swift
        if row == 0 {
            pickerView.selectRow(1, inComponent: component, animated: true)
        }
        if let valueChanged = self.valueChanged {
            valueChanged(pickerDataSource[row])
        }
    }
}

class LocationCell: OptionCell {
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationTextField: UITextField!
    var valueChanged : ((String?) -> Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.locationTextField.delegate = self
        self.locationTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let valueChanged = self.valueChanged {
            valueChanged(locationTextField.text)
        }
    }
}

// push the view up when a keyboard shows
extension LocationCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.resignFirstResponder()
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) { // became first responder
        
        //move textfields up
        let myScreenRect: CGRect = UIScreen.main.bounds
        let keyboardHeight : CGFloat = 216
        let navBarHeight: CGFloat = 44
        
        UIView.beginAnimations( "animateView", context: nil)
        var needToMove: CGFloat = 0
        
        var frame : CGRect = self.superview!.frame
        if (textField.frame.origin.y + textField.frame.size.height + navBarHeight + UIApplication.shared.statusBarFrame.size.height > (myScreenRect.size.height - keyboardHeight)) {
            needToMove = (textField.frame.origin.y + textField.frame.size.height + navBarHeight + UIApplication.shared.statusBarFrame.size.height) - (myScreenRect.size.height - keyboardHeight);
        }
        frame.origin.y = -needToMove
        self.superview!.frame = frame
        UIView.commitAnimations()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //move textfields back down
        UIView.beginAnimations( "animateView", context: nil)
        var frame : CGRect = self.superview!.frame
        frame.origin.y = 0
        self.superview!.frame = frame
        UIView.commitAnimations()
    }
}
