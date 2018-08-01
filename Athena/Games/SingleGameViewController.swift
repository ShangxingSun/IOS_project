//
//  SingleGameViewController.swift
//  Athena
//
//  Created by Weijia Duan on 11/1/17.
//  Copyright © 2017 Sportcraft. All rights reserved.
//

import UIKit

// MARK: Registered games displaying interface for a specific kind of game

class SingleGameViewController: UITableViewController {

    var gameType: GameName = .Squash
    var registeredGames: [Game] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.sectionHeaderHeight = 30
        self.tableView.register(UINib.init(nibName: "gameTableViewCell", bundle: nil), forCellReuseIdentifier: "gameCellNib")
        tableView.allowsSelection = false
    }
    
    func refreshPage(){
        let allUpGames = getAllUpGames(allGames: handler.allGamesLocal)
        registeredGames = allUpGames[gameType] ?? []
        tableView.reloadData()
        print("Registered game page refreashed.")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return registeredGames.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "gameCellNib", for: indexPath) as! gameTableViewCell
        
        let game = registeredGames[indexPath.row]
        cell.Host.text = "by " + (handler.getUser(userID: game.owner)?.firstName ?? "Anonymous")
        
        cell.Player.text = "Current player: " +  String(game.player.count + 1)
        cell.Difficulty.text = "Level " + String(game.level)
        cell.Location.text = game.location
        cell.Time.text = game.startTime.formatedDate
        cell.Duration.text = game.startTime.formatedTime + " | " + game.endTime.offsetFrom(date: game.startTime)
        cell.gameImg.image = ballImage[game.gameName]
        if game.isFull() {
            cell.joinGame.filled()
        }
        else{
            cell.joinGame.available()
        }
        if handler.currentUser.myGame.contains(game.gameID) {
            cell.joinGame.joined()
        }
        configButton(game: game, cell: cell)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func configButton(game: Game, cell: gameTableViewCell){
        cell.joinButtonTapped = {
            if handler.currentUser.gameDict[game.gameName] == nil {
                let alert = UIAlertController(title: "You have not specified your skill level for " + game.gameName.rawValue, message: "Go to the profile page to register first", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                let alertMsg = (handler.currentUser.gameDict[game.gameName]! != game.level) ?  "Your skill level does not match this game. Join anyway?" : "Are you sure to join this game?"
                let alert = UIAlertController(title: alertMsg, message: nil, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.cancel, handler: nil))
                //event handler with closure
                alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: {(action: UIAlertAction) in
                    if handler.joinExistingGame(game: game) {
                        print("Game joined.")
                    }
                    self.refreshPage()
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func cancelButtonReturnToSingleGames(segue: UIStoryboardSegue) {}
   
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "singleGameToAddNewGame"){
            let destinationVC = (segue.destination as! UINavigationController).topViewController as! CreateNewGameTableViewController
            destinationVC.gameType = self.gameType
        }
    }
    
}
