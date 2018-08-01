//
//  InterfaceDataModel.swift
//  Athena
//
//  Created by Ellie Zheng on 11/20/2017.
//  Copyright © 2017 Sportcraft. All rights reserved.
//

import UIKit

typealias GameDict = [GameName: [Game]]

// MARK: Given an array of all the games saved in Firebase, return a dictionary of all upcoming games
func getAllUpGames(allGames: [Game]) -> GameDict {
    var allUpComingGames: GameDict = [:]
    for game in allGames{
        if game.startTime.hasPassed { continue }
        if allUpComingGames[game.gameName] == nil {
            allUpComingGames[game.gameName] = [game]
        } else {
            allUpComingGames[game.gameName]?.append(game)
        }
    }
    return allUpComingGames
}
extension UIViewController {
    func addLoadingView() -> UIView {
        let popupViewWidth: CGFloat = 60
        let popupViewHeight: CGFloat = 60
        let popupFrame = CGRect(x: (view.frame.width - popupViewWidth)/2, y: (view.frame.height - popupViewHeight)*0.4, width: popupViewWidth, height: popupViewHeight)
        
        let loadingView = UIView(frame: popupFrame)
        loadingView.backgroundColor = UIColor.black
        loadingView.layer.cornerRadius = 10
        loadingView.layer.shadowColor = UIColor.white.cgColor
        loadingView.layer.shadowOffset = CGSize(width: 0, height: 0)
        loadingView.layer.shadowOpacity = 0.8
        loadingView.layer.shadowRadius = 4.0
        loadingView.alpha = 0.8
        self.view.superview?.addSubview(loadingView)
        let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        activityIndicator.alpha = 1.0
        loadingView.addSubview(activityIndicator)
        activityIndicator.center = CGPoint(x: loadingView.bounds.size.width / 2, y: loadingView.bounds.size.height / 2)
        activityIndicator.startAnimating()
        
        let popupTextField = UITextField(frame: CGRect(x: (loadingView.bounds.width - 200)/2, y: 10, width: 200, height: 50))
        popupTextField.isUserInteractionEnabled = false
        popupTextField.text = "Pairing..."
        popupTextField.font = UIFont(name: "Verdana", size: 18)
        popupTextField.textColor = UIColor.white
        popupTextField.textAlignment = .center
        //loadingView.addSubview(popupTextField)
        return loadingView
    }
}
extension NSDate {
    // NSDate(dateString:"2014-06-06 22:31")
    convenience init(dateString: String) {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        dateStringFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale!
        let someDateTime = dateStringFormatter.date(from: dateString)!
        self.init(timeInterval: 0, since: someDateTime)
    }
    func isGreaterThanDate(dateToCompare: NSDate) -> Bool {
        return (self.compare(dateToCompare as Date) == ComparisonResult.orderedDescending) ? true : false
    }
    func isLessThanDate(dateToCompare: NSDate) -> Bool {
        return (self.compare(dateToCompare as Date) == ComparisonResult.orderedAscending) ? true : false
    }
    var hasPassed: Bool {
        return self.isLessThanDate(dateToCompare: NSDate())
    }
    func getHour() -> Int {
        let calendar = NSCalendar.current
        let comp = calendar.dateComponents([.hour, .minute], from: self as Date)
        return comp.hour!
    }
    func offsetFrom(date: NSDate) -> String {
        let hourMin: Set<Calendar.Component> = [.hour, .minute]
        let difference = NSCalendar.current.dateComponents(hourMin, from: date as Date, to: self as Date)
        var output: String = ""
        if let hours = difference.hour {
            if hours > 0 { output += "\(hours)h " }
        }
        if let minutes = difference.minute {
            if minutes > 0 { output += "\(minutes)m" }
        }
        return output
    }
    var formatedDate: String {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = "MMM dd, yyyy"
        return dateStringFormatter.string(from: self as Date)
    }
    var formatedTime: String {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = "EEE, h:mm a"
        return dateStringFormatter.string(from: self as Date)
    }
    var formatedTimeOnly: String {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = "h:mm a"
        return dateStringFormatter.string(from: self as Date)
    }
    static func combineDateWithTime(date: NSDate, time: NSDate) -> Date? {
        let calendar = NSCalendar.current
        
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date as Date)
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: time as Date)
        
        var mergedComponments = DateComponents()
        mergedComponments.year = dateComponents.year!
        mergedComponments.month = dateComponents.month!
        mergedComponments.day = dateComponents.day!
        mergedComponments.hour = timeComponents.hour!
        mergedComponments.minute = timeComponents.minute!
        //mergedComponments.second = timeComponents.second!
        
        return calendar.date(from: mergedComponments)
    }
}

// MARK: Call self.hideKeyboard() in the viewDidLoad
// Taken from StackOverflow "How to dismiss keyboard when touching anywhere outside UITextField (in swift)?"
extension UIViewController{
    func hideKeyboard(){
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
}

