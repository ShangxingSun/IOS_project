//
//  HomePageViewController.swift
//  Athena
//
//  Created by Weijia Duan on 11/1/17.
//  Copyright © 2017 Sportcraft. All rights reserved.
//

import UIKit

// MARK: Home page interface after login or sign up.

class HomePageViewController: UITableViewController {

    var allUpGames: GameDict!
    let ballList: [GameName] = [.Squash, .Tennis, .Badminton]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // load data
        allUpGames = getAllUpGames(allGames: handler.allGamesLocal)
        // pull to refresh
        refreshControl = UIRefreshControl()
        self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refersh")
        self.refreshControl?.addTarget(self, action: #selector(refreshPage(_:)), for: UIControlEvents.valueChanged)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        allUpGames = getAllUpGames(allGames: handler.allGamesLocal)
        self.tableView.reloadData()
    }
    
    @objc func refreshPage(_ refreshControl: UIRefreshControl) {
        handler.asyncGroup = DispatchGroup()
        handler.refresh()
        handler.asyncGroup!.notify(queue: DispatchQueue.main, execute: {
            handler.asyncGroup = nil
            //loadingView.removeFromSuperview()
            self.allUpGames = getAllUpGames(allGames: handler.allGamesLocal)
            refreshControl.endRefreshing()
            self.tableView.reloadData()
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ballList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! HomePageTableViewCell
        cell.ballImage.image = ballImage[ballList[indexPath.row]]
        let num = allUpGames[ballList[indexPath.row]]?.count ?? 0
        cell.gameTitle.text = ballList[indexPath.row].rawValue
        cell.info.text = "Active games: \(num)"
        return cell
    }
    
    @IBAction func returnToHomePage(segue: UIStoryboardSegue) {}

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using
        let destinationVC = segue.destination as! SingleGameViewController
        // Pass the selected object to the new view controller.
        let currentIndexPath = tableView.indexPathForSelectedRow!
        let selectedGame: GameName = ballList[currentIndexPath.row]
        destinationVC.gameType = selectedGame
        destinationVC.registeredGames = allUpGames[selectedGame] ?? []
    }
    
}

class HomePageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var ballImage: UIImageView!
    @IBOutlet weak var gameTitle: UILabel!
    @IBOutlet weak var info: UILabel!
    
}
