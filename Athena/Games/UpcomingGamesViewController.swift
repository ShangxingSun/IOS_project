//
//  GamesViewController.swift
//  Athena
//
//  Created by Weijia Duan on 11/1/17.
//  Copyright © 2017 Sportcraft. All rights reserved.
//

import UIKit

// MARK: Upcoming games interface for Athena

class UpcomingGamesViewController: UITableViewController {

    var upComingGames: GameDict = [:]
    var gameSections: [GameSection] = []
    var completed: Bool { return false }
    var toBeEdit: Game?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Configuring table cells
        self.tableView.register(UINib.init(nibName: "gameTableViewCell", bundle: nil), forCellReuseIdentifier: "gameCellNib")
        self.tableView.allowsSelection = false
        
        // pull to refresh
        refreshControl = UIRefreshControl()
        self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refersh")
        self.refreshControl?.addTarget(self, action: #selector(refreshPage(_:)), for: UIControlEvents.valueChanged)
        
        // load data
        upComingGames = handler.currentUser.getUpcomingAndCompletedGames(allGames: handler.allGamesLocal).0
        gameSections = getSections(gameDict: upComingGames)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        upComingGames = handler.currentUser.getUpcomingAndCompletedGames(allGames: handler.allGamesLocal).0
        gameSections = getSections(gameDict: upComingGames)
        self.tableView.reloadData()
    }
    
    @objc func refreshPage(_ refreshControl: UIRefreshControl) {
        print("refreshing upcoming games")
        handler.asyncGroup = DispatchGroup()
        //let loadingView = addLoadingView()
        handler.refresh()
        handler.asyncGroup!.notify(queue: DispatchQueue.main, execute: {
            handler.asyncGroup = nil
            //loadingView.removeFromSuperview()
            self.upComingGames = handler.currentUser.getUpcomingAndCompletedGames(allGames: handler.allGamesLocal).0
            self.gameSections = getSections(gameDict: self.upComingGames)
            refreshControl.endRefreshing()
            self.tableView.reloadData()
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return gameSections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gameSections[section].expanded ? gameSections[section].games.count : 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "gameCellNib", for: indexPath) as! gameTableViewCell
        
        let game = gameSections[indexPath.section].games[indexPath.row]
        cell.Host.text = "by " + (handler.getUser(userID: game.owner)?.firstName ?? "Anonymous")
        cell.Player.text = "Current player: " +  String(game.player.count + 1)
        cell.Difficulty.text = "Level " + String(game.level)
        cell.Location.text = game.location
        cell.Time.text = game.startTime.formatedDate
        cell.Duration.text = game.startTime.formatedTime + " | " + game.endTime.offsetFrom(date: game.startTime)
        cell.gameImg.image = ballImage[game.gameName]
        if game.owner == handler.currentUser.getKey() {
            cell.joinGame.edit()
        } else{
            cell.joinGame.quit()
        }
        if completed {cell.joinGame.isHidden = true}
        configButton(game: game, cell: cell)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return (section < gameSections.count - 1) ? 2 : 0
    }
    
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        view.tintColor = UIColor(white: 1.3, alpha: 0.55)
    }
    
    @IBAction func returnToUpcomingGames(segue: UIStoryboardSegue) {
        refreshPage(UIRefreshControl())
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "upcomingToAddNewGame") && (toBeEdit != nil) {
            let destinationVC = (segue.destination as! UINavigationController).topViewController as! CreateNewGameTableViewController
            destinationVC.gameToBeEdit = self.toBeEdit!
            destinationVC.navigationItem.title = "Edit Game Details"
            self.toBeEdit = nil
        }
    }
    
    // MARK: Define the behavior of the button
    
    func configButton(game: Game, cell: gameTableViewCell) {
        cell.editButtonTapped = {
            self.toBeEdit = game
            self.performSegue(withIdentifier: "upcomingToAddNewGame", sender: nil)
        }
        cell.quitButtonTapped = {
            let alert = UIAlertController(title: "Are you sure to quit this game?", message: nil, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.cancel, handler: nil))
            //event handler with closure
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: {(action: UIAlertAction) in
                if handler.quitExistingGame(game: game){
                    print("Game quited.")
                }
                self.refreshPage(UIRefreshControl())
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension UpcomingGamesViewController: ExpandableHeaderViewDelegate {
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = ExpandableHeaderView()
        let title = gameSections[section].expanded ? ("\u{25BC}  " + gameSections[section].gameType.rawValue) : ("\u{25B6}  " + gameSections[section].gameType.rawValue)
        header.customInit(title: title, section: section, delegate: self)
        return header
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    func toggleSection(header: ExpandableHeaderView, section: Int){
        gameSections[section].expanded = !gameSections[section].expanded
        tableView.reloadSections(NSIndexSet(index: section) as IndexSet, with: .automatic)
        /*
        tableView.beginUpdates()
        for i in 0 ..< gameSections[section].games.count {
            tableView.reloadRows(at: [IndexPath(row: i, section: section)], with: .automatic)
        }
        tableView.endUpdates()
         */
    }
}

// MARK: Data structures that are used in the "my upcoming/completed games" scenes

struct GameSection {
    var gameType: GameName = GameName.Squash
    var games: [Game] = []
    var expanded: Bool = true
    init(_ gameType: GameName, _ games: [Game]){
        self.gameType = gameType
        self.games = games
    }
}

func getSections(gameDict: GameDict) -> [GameSection] {
    var gameSections: [GameSection] = []
    for (gameType, gamesArray) in gameDict{
        gameSections.append(GameSection(gameType, gamesArray))
    }
    return gameSections
}
