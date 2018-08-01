//
//  DataHandler.swift
//  Athena
//
//  Created by Ellie on 11/24/2017.
//  Copyright © 2017 Sportcraft. All rights reserved.
//

import UIKit
import Firebase

// Globel variable that saves data locally and provides interfaces between the view controllers and the database
var handler = DataHandler()

class DataHandler {
    // variables that save the fetched data
    var currentUser: User!
    var allGamesLocal: [Game] = []
    var allUsersLocal: [User] = []
    
    var lastUser: User? = user1
    var loadingGroup: DispatchGroup?
    var asyncGroup: DispatchGroup?
    
    var bufferAllGames: [Game] = []
    
    // Given a User object,
    // if it does not exist in the database, then add it to the database;
    // if it exists, then update it in the database
    func save(user: User) -> Bool {
        user.uploadUser()
        return true
    }
    // Given a Game object,
    // if it does not exist in the database, then add it to the database;
    // if it exists, then update it in the database
    func save(game: Game) -> Bool {
        game.uploadGame()
        return true
    }
    
    // remove a game from the database
    func delete(gameID: String) -> Bool {
        for index in 0 ..< allGamesLocal.count{
            if allGamesLocal[index].gameID == gameID{
                allGamesLocal[index].isDeleted =  1
                allGamesLocal[index].uploadGame()
                return true
            }
        }
        return false
    }
    // get the current user and all games from the database to the local variables
    func refresh() {
        asyncGroup!.enter()
        loadingGroup = DispatchGroup()
        getAllGames(group: loadingGroup!)
        getAllUsers(group: loadingGroup!)
        loadingGroup!.notify(queue: DispatchQueue.main, execute: {
            self.allGamesLocal = self.getUnDeletedGame(allGames: self.bufferAllGames)
            if self.currentUser != nil {
                self.currentUser = self.getUser(userID: self.currentUser.getKey())
            }
            self.loadingGroup = nil
            self.bufferAllGames = []
            print("users and games loaded from firebase")
            self.asyncGroup!.leave()
        })
        //return (currentUser == nil) ? false : true
        
    }
    // Given the userID, fetch the User object from the local user array. Return nil if not found.
    func getUser(userID: String) -> User? {
        // Firebase implementation required
        var index: Int? = nil
        for i in 0 ..< self.allUsersLocal.count {
            if self.allUsersLocal[i].getKey() == userID {
                index = i
            }
        }
        return (index == nil) ? nil : self.allUsersLocal[index!]
    }
    //
    // The following functions should be called for login/signup
    //
    func logIn(userEmail: String, password: String) -> Int {
        // Followings are for simple password string matching
        // call refresh() first
        let targetUser = getUser(userID: emailParser(inputEmail: userEmail))
        //print(targetUser!.description())
        if targetUser == nil { return 1 }
        if targetUser!.password == password {
            currentUser = targetUser
            return 0
        } else { return 2 }
    }
    func signUp(newUser: User) -> Bool {
        // call refresh() first
        currentUser = newUser
        return currentUser.saveUser()
    }
    func updateProfile(newVersion: User) -> Bool {
        if !newVersion.saveUser() { return false }
        currentUser = newVersion
        return true
    }
    private func getAllUsers(group: DispatchGroup){
        ref = Database.database().reference()
        group.enter()
        ref.child("User").observeSingleEvent(of: .value, with: { (snapshot) in
            let NSDict = snapshot.value as? NSDictionary ?? nil
            if NSDict == nil{
                group.leave()
                return
            }
            if NSDict!.count == 0{
                group.leave()
                return
            }
            for (_,oneNSDict) in NSDict!{
                let downloadNSDict = oneNSDict as! NSDictionary
                if downloadNSDict.count != 0 {
                    let downloadUser = User(firstName: "", lastName: "", email: "", password: "", myGame: [], gameDict: [:])
                    downloadUser.firstName = downloadNSDict["firstName"] as! String
                    downloadUser.lastName = downloadNSDict["lastName"] as! String
                    downloadUser.email = downloadNSDict["email"] as! String
                    downloadUser.password = downloadNSDict["password"] as! String
                    downloadUser.myGame = downloadNSDict["myGame"] as? [String] ?? [""]
                    var toGameDict = [GameName:Int]()
                    let downloadGameDict = downloadNSDict["gameDict"] as! [String:String]
                    for (game,level) in downloadGameDict{
                        if game == GameName.Squash.rawValue{
                            toGameDict[GameName.Squash] = Int(level)!
                        }else if game == GameName.Tennis.rawValue{
                            toGameDict[GameName.Tennis] = Int(level)!
                        }else{
                            toGameDict[GameName.Badminton] = Int(level)!
                        }
                    }
                    downloadUser.gameDict = toGameDict
                    self.allUsersLocal.append(downloadUser)
                }
            }
            group.leave()
        })
    }
    private func getAllGames(group: DispatchGroup){
        ref = Database.database().reference()
        group.enter()
        ref.child("Games").observeSingleEvent(of: .value, with: { (snapshot) in
            let NSDict = snapshot.value as? NSDictionary ?? nil
            if NSDict == nil{
                group.leave()
                return
            }
            if NSDict!.count == 0{
                group.leave()
                return
            }
            for (k,oneNSDict) in NSDict!{
                let downloadNSDict = oneNSDict as! NSDictionary
                let key = k as! String
                //print(downloadNSDict)
                //print(key)
                let downloadGame = Game(gameName: GameName.Squash, location: "no", startTime: NSDate(), endTime: NSDate(), owner: "no", player: [], level:0, maxPlayer: 0,isDeleted:0)
                downloadGame.gameID = key
                let gameN =  downloadNSDict["gameName"] as!String
                if gameN == "Squash"{
                    downloadGame.gameName = GameName.Squash
                }else if gameN == "Tennis"{
                    downloadGame.gameName = GameName.Tennis
                }else {
                    downloadGame.gameName = GameName.Badminton
                }
                downloadGame.location = downloadNSDict["location"] as! String
                let starTinterval = downloadNSDict["startTime"] as! String
                let endTinterval =  downloadNSDict["endTime"] as! String
                downloadGame.startTime = NSDate(timeIntervalSince1970: Double(starTinterval)!)
                downloadGame.endTime = NSDate(timeIntervalSince1970: Double(endTinterval)!)
                downloadGame.owner = downloadNSDict["owner"] as! String
                downloadGame.player = (downloadNSDict["player"] != nil) ? (downloadNSDict["player"] as! [String]) : []
                downloadGame.level = Int(downloadNSDict["level"] as! String)!
                downloadGame.maxPlayer = Int(downloadNSDict["maxPlayer"] as! String)!
                downloadGame.isDeleted = Int(downloadNSDict["isDeleted"] as! String)!
                self.bufferAllGames.append(downloadGame)
            }
            group.leave()
        })
        
    }
    func getUnDeletedGame(allGames: [Game]) -> [Game] {
        var openGames: [Game] = []
        for onegame in allGames{
            if onegame.isDeleted != 1{
                openGames.append(onegame)
            }
        }
        return openGames
    }
    //
    // The following functions should be called when the current user make changes to the games
    //
    func addNewGame(game: Game) -> Bool {
        if !game.saveGame() { return false }
        if !currentUser.addGame(gameID: game.gameID) { return false }
        //if !refresh() { return false }
        return true
    }
    func joinExistingGame(game: Game) -> Bool {
        if !game.addPlayer(userID: currentUser.getKey()) { return false }
        if !currentUser.addGame(gameID: game.gameID) { return false }
        //if !refresh() { return false }
        return true
    }
    func quitExistingGame(game: Game) -> Bool {
        if !game.removePlayer(userID: currentUser.getKey()) { return false }
        if !currentUser.removeGame(gameID: game.gameID) { return false }
        //if !refresh() { return false }
        return true
    }
    func editOwnGame(gameID: String, newVersion: Game) -> Bool {
        newVersion.gameID = gameID
        if !newVersion.saveGame() { return false }
        //if !refresh() { return false }
        return true
    }
    func deleteExistingGame(game: Game) -> Bool {
        if !currentUser.removeGame(gameID: game.gameID) { return false }
        let otherPlayers = game.player
        for playerID in otherPlayers {
            if let player = getUser(userID: playerID){
                if !player.removeGame(gameID: game.gameID) { return false }
            } else { return false }
        }
        if !self.delete(gameID: game.gameID) { return false }
        //if !refresh() { return false }
        return true
    }
}

extension User {
    func getKey() -> String { return emailParser(inputEmail: self.email) }
    
    func addGame(gameID: String) -> Bool {
        myGame.append(gameID)
        return saveUser()
    }
    func removeGame(gameID: String) -> Bool {
        myGame.remove(object: gameID)
        return saveUser()
    }
    func saveUser() -> Bool {
        return handler.save(user: self)
    }
    func getUpcomingAndCompletedGames(allGames: [Game]) -> (GameDict, GameDict) {
        var myUpComingGames: GameDict = [:]
        var myCompletedGames: GameDict = [:]
        for game in allGames {
            if myGame.contains(game.gameID) {
                if game.startTime.hasPassed {
                    if myCompletedGames[game.gameName] == nil {
                        myCompletedGames[game.gameName] = [game]
                    } else {
                        myCompletedGames[game.gameName]?.append(game)
                    }
                } else {
                    if myUpComingGames[game.gameName] == nil {
                        myUpComingGames[game.gameName] = [game]
                    } else {
                        myUpComingGames[game.gameName]?.append(game)
                    }
                }
                
            }
        }
        return (myUpComingGames, myCompletedGames)
    }
}
extension Game {
    func isFull() -> Bool {
        return (maxPlayer <= player.count+1) ? true : false
    }
    func saveGame() -> Bool {
        return handler.save(game: self)
    }
    func addPlayer(userID: String) -> Bool {
        player.append(userID)
        return saveGame()
    }
    func removePlayer(userID: String) -> Bool {
        player.remove(object: userID)
        return saveGame()
    }
}

extension Array where Element: Equatable {
    // Remove first collection element that is equal to the given `object`:
    mutating func remove(object: Element) {
        if let index = index(of: object) {
            remove(at: index)
        }
    }
}

// fake data
let user1 = User(firstName: "Tom", lastName: "Hanks", email: "tom.hanks@gmail.com", password: "1234", myGame: ["1", "3", "4", "6"], gameDict: [.Squash: 2, .Tennis: 3])

