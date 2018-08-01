//
//  CompletedGamesViewController.swift
//  Athena
//
//  Created by Weijia Duan on 11/1/17.
//  Copyright © 2017 Sportcraft. All rights reserved.
//

import UIKit

// MARK: Completed game interface for Athena. Displaying past games for the user.

class CompletedGamesViewController: UpcomingGamesViewController {
    var completedGames: GameDict = [:]
    override var completed: Bool { return true }
    override func viewDidLoad() {
        super.viewDidLoad()
        // load data
        completedGames = handler.currentUser.getUpcomingAndCompletedGames(allGames: handler.allGamesLocal).1
        gameSections = getSections(gameDict: completedGames)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        completedGames = handler.currentUser.getUpcomingAndCompletedGames(allGames: handler.allGamesLocal).1
        gameSections = getSections(gameDict: completedGames)
        self.tableView.reloadData()
    }
    
    @objc override func refreshPage(_ refreshControl: UIRefreshControl) {
        handler.asyncGroup = DispatchGroup()
        handler.refresh()
        handler.asyncGroup!.notify(queue: DispatchQueue.main, execute: {
            handler.asyncGroup = nil
            //loadingView.removeFromSuperview()
            self.completedGames = handler.currentUser.getUpcomingAndCompletedGames(allGames: handler.allGamesLocal).1
            self.gameSections = getSections(gameDict: self.completedGames)
            refreshControl.endRefreshing()
            self.tableView.reloadData()
        })
        
    }
}
