//
//  DataModel.swift
//  firebaseUseExample
//
//  Created by Shangxing Sun on 11/15/17.
//  Copyright © 2017 Shangxing Sun. All rights reserved.
//

import Foundation
import UIKit
import Firebase
var ref:DatabaseReference!
enum GameName: String{
    case Squash = "Squash"
    case Tennis = "Tennis"
    case Badminton = "Badminton"
}
class User {
    var firstName:String
    var lastName:String
    var email:String
    var password:String
    var myGame:[String]
    var gameDict:[GameName:Int]
    init(firstName:String,lastName:String,email:String,password:String,myGame:[String],gameDict:[GameName:Int]){
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.password = password
        self.myGame = myGame
        self.gameDict = gameDict
        
    }
    
    func uploadUser(){
        var toStringGameDict = [String:String]()
        for (game,level) in self.gameDict{
            toStringGameDict[game.rawValue] = String(level)
        }
        //self.email=emailParser(inputEmail: self.email)
        let uploadUserDict:NSDictionary = ["firstName":self.firstName,
                                           "lastName":self.lastName,
                                           "email":self.email,
                                           "password":self.password,
                                           "myGame":self.myGame,
                                           "gameDict":toStringGameDict]
        ref = Database.database().reference().child("User").child(self.getKey())
        ref.setValue(uploadUserDict)
    }
    func loadUser(group: DispatchGroup, email:String) -> Bool{
        let Pemail = emailParser(inputEmail: email)
        ref = Database.database().reference().child("User").child(Pemail)
        var isSuccess:Bool = false
        group.enter()
        ref.observeSingleEvent(of: .value, with: {
            (snapshot) in
            let downloadNSDict = snapshot.value as? NSDictionary ?? nil
            if downloadNSDict != nil{
                if downloadNSDict!.count != 0{
                    self.firstName = downloadNSDict!["firstName"] as! String
                    self.lastName = downloadNSDict!["lastName"] as! String
                    self.email = downloadNSDict!["email"] as! String
                    self.password = downloadNSDict!["password"] as! String
                    self.myGame = downloadNSDict!["myGame"] as? [String] ?? [""]
                    var toGameDict = [GameName:Int]()
                    let downloadGameDict = downloadNSDict!["gameDict"] as! [String:String]
                    for (game,level) in downloadGameDict{
                        if game == GameName.Squash.rawValue{
                            toGameDict[GameName.Squash] = Int(level)!
                        }else if game == GameName.Tennis.rawValue{
                            toGameDict[GameName.Tennis] = Int(level)!
                        }else{
                            toGameDict[GameName.Badminton] = Int(level)!
                        }
                    }
                    self.gameDict = toGameDict
                    isSuccess = true
                }else{
                    isSuccess = false
                }
            }else{
                isSuccess = false
            }
            print("signed")
            group.leave()
            
        }, withCancel: {(error) in
            print("canceled")
            print(error.localizedDescription)
            isSuccess = false
            group.leave()
        })
        print(self.description())
        return isSuccess
    }
    func description() -> String{
        var description = "i am " + self.firstName + " " + self.lastName + " my email is " + self.email + "my password is " + self.password + " my game is "
        for game in self.myGame{
            description += game
        }
        for (gameName,level) in self.gameDict{
            description += gameName.rawValue + "with level " + String(level)
        }
        return description
    }
    
}
class Game{
    var gameID:String
    var gameName:GameName
    var location:String
    var startTime:NSDate
    var endTime:NSDate
    var owner:String
    var player:[String]
    var level:Int
    var maxPlayer:Int
    var isDeleted:Int
    //0 for normal, 1 for deleted game
    init(gameName:GameName,location:String,startTime:NSDate,endTime:NSDate,owner:String,player:[String],level:Int,maxPlayer:Int,isDeleted:Int = 0){
        self.gameID = ""
        self.gameName = gameName
        self.location = location
        self.startTime = startTime
        self.endTime = endTime
        self.owner = owner
        self.player = player
        self.level = level
        self.maxPlayer = maxPlayer
        self.isDeleted=isDeleted
    }
    func uploadGame() {
        let starTintervel = self.startTime.timeIntervalSince1970
        let endTinterval = self.endTime.timeIntervalSince1970
        let currentTime:NSDate = NSDate(timeIntervalSinceNow: 0)
        let currentTimeString = String(currentTime.timeIntervalSince1970).replacingOccurrences(of: ".", with: "-")
        let uploadNSDict:NSDictionary = ["gameName" : self.gameName.rawValue,
                                         "location" : self.location,
                                         "startTime" : String(starTintervel),
                                         "endTime" : String(endTinterval),
                                         "owner" : self.owner,
                                         "player" : self.player,
                                         "level" : String(self.level),
                                         "maxPlayer" : String(self.maxPlayer),
                                         "isDeleted": String(self.isDeleted)]
        var ref: DatabaseReference!
        if self.gameID == ""{
            ref = Database.database().reference().child("Games").child(currentTimeString)
            gameID = currentTimeString
            ref.setValue(uploadNSDict)
        }else{
            ref = Database.database().reference().child("Games").child(self.gameID)
            ref.setValue(uploadNSDict)
        }
    }
    func loadGame(gameID:String){
        var downloadNSDict = NSDictionary()
        var ref: DatabaseReference!
        ref = Database.database().reference()
        ref.ref.child("Games").child(gameID).observeSingleEvent(of: .value, with: { (snapshot) in
            downloadNSDict = snapshot.value as! NSDictionary
            print(snapshot)
            print(downloadNSDict)
            self.gameID = gameID
            let gameN =  downloadNSDict["gameName"] as!String
            if gameN == "Squash"{
                self.gameName = GameName.Squash
            }else if gameN == "Tennis"{
                self.gameName = GameName.Tennis
            }else {
                self.gameName = GameName.Badminton
            }
            self.location = downloadNSDict["location"] as! String
            let starTinterval = downloadNSDict["startTime"] as! String
            let endTinterval =  downloadNSDict["endTime"] as! String
            self.startTime = NSDate(timeIntervalSince1970: Double(starTinterval)!)
            self.endTime = NSDate(timeIntervalSince1970: Double(endTinterval)!)
            self.owner = downloadNSDict["owner"] as! String
            self.player = downloadNSDict["player"] as! [String]
            self.level = Int(downloadNSDict["level"] as! String)!
            self.maxPlayer = Int(downloadNSDict["maxPlayer"] as! String)!
            self.isDeleted = Int(downloadNSDict["maxPlayer"] as! String)!
        })
    }
    func isCompleted() -> Bool{
        let currentTime = NSDate(timeIntervalSinceNow: 0)
        if self.endTime.timeIntervalSince1970 > currentTime.timeIntervalSince1970{
            return false
        }else{
            return true
        }
    }
    func isGameFull() -> Bool{
        if self.player.count >= self.maxPlayer{
            return true
        }else{
            return false
        }
    }
    func description() -> String{
        var description:String = self.gameID + " which is " + self.gameName.rawValue + " where at " + self.location
        description += String(describing: self.startTime) + String(describing: self.endTime) + " owner is " + self.owner
        for oneplayer in self.player{
            description += oneplayer + " "
        }
        description += " level is " + String(self.level) + "maxPlayer is " + String(self.maxPlayer)
        return description
    }
}
func emailParser(inputEmail:String) -> String{
    let resultEmail = inputEmail.replacingOccurrences(of: "@", with: "")
    let finalEmail = resultEmail.replacingOccurrences(of: ".", with: "")
    return finalEmail
}

