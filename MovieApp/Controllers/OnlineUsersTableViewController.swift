//
//  OnlineUsersTableViewController.swift
//  MovieApp
//
//  Created by Jimi Duiveman on 11-12-17.
//  Copyright © 2017 Jimi Duiveman. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth


class OnlineUsersTableViewController: UITableViewController {
  
    let usersRef = Database.database().reference(withPath: "online")
    let userCell = "userCell"
    
    
    var currentUsers: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Display online users in tableView
        usersRef.observe(.childAdded, with: { snap in
            guard let email = snap.value as? String else { return }
            self.currentUsers.append(email)
            let row = self.currentUsers.count - 1
            let indexPath = IndexPath(row: row, section: 0)
            self.tableView.insertRows(at: [indexPath], with: .top)
        })
        
        // Remove user from currentUsers and update tableView
        usersRef.observe(.childRemoved, with: { snap in
            guard let emailToFind = snap.value as? String else { return }
            for (index, email) in self.currentUsers.enumerated() {
                if email == emailToFind {
                    let indexPath = IndexPath(row: index, section: 0)
                    self.currentUsers.remove(at: index)
                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                }
            }
        })
        
        // No lines between rows
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
    }
  
  
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentUsers.count
    }
  
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: userCell, for: indexPath)
        let onlineUserEmail = currentUsers[indexPath.row]
        cell.textLabel?.text = onlineUserEmail
        cell.textLabel?.textColor = UIColor.white
        return cell
    }
  

    
    @IBAction func signoutButtonPressed(_ sender: AnyObject) {
        if Auth.auth().currentUser != nil {
            // There is a user signed in
            do {
                // Sign out the current user
                try? Auth.auth().signOut()
                
                // If signed out, go to loginViewController
                if Auth.auth().currentUser == nil {
                    dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    

  
}
