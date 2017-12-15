//
//  MoviesCollectionViewController.swift
//  MovieApp
//
//  Created by Jimi Duiveman on 09-12-17.
//  Copyright © 2017 Jimi Duiveman. All rights reserved.
//


//https://www.raywenderlich.com/136159/uicollectionview-tutorial-getting-started


import UIKit
import Firebase


class MoviesCollectionViewController: UICollectionViewController {

    fileprivate let sectionInsets = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
    fileprivate let itemsPerRow: CGFloat = 3
    fileprivate let reuseIdentifier = "movieCell"
    
    
    // Segues
    let toOnlineUsers = "toOnlineUsers"
    let toWatchList  = "toWatchList"
    let toDetailMovie = "toDetailMovie"
    
    let usersRef = Database.database().reference(withPath: "online")
    
    var user: User!
    var userCountBarButtonItem: UIBarButtonItem!
    
    var movies = [Movie]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create bar button
        userCountBarButtonItem = UIBarButtonItem(title: "1", style: .plain, target: self, action: #selector(userCountButtonDidTouch))
        userCountBarButtonItem.tintColor = UIColor.white
        navigationItem.leftBarButtonItem = userCountBarButtonItem
        
        // Make button display number of online users
        Auth.auth().addStateDidChangeListener { auth, user in
            guard let user = user else { return }
            self.user = User(authData: user)
            
            let currentUserRef = self.usersRef.child(self.user.uid)
            currentUserRef.setValue(self.user.email)
            currentUserRef.onDisconnectRemoveValue()
        }
        
        usersRef.observe(.value, with: { snapshot in
            if snapshot.exists() {
                self.userCountBarButtonItem?.title = snapshot.childrenCount.description
            } else {
                self.userCountBarButtonItem?.title = "0"
            }
        })
        
        // Get movies from API
        MovieController.shared.fetchMovieItems() { (movies) in
            if let movies = movies {
                self.updateUI(with: movies)
            }
        }
        
        
        
        // Create blue line under navbar
        if let navigationController = self.navigationController {
            let navigationBar = navigationController.navigationBar
            let navigationSeparator = UIView(frame: CGRect(x:0, y:navigationBar.frame.size.height - 1, width:navigationBar.frame.size.width, height:0.5))
            navigationSeparator.backgroundColor = #colorLiteral(red: 0.2284384445, green: 0.5989627731, blue: 1, alpha: 1)
            navigationSeparator.isOpaque = true
            self.navigationController?.navigationBar.addSubview(navigationSeparator)
        }
        
    }
    
    // Assign movies to variable in viewController
    func updateUI(with movies: [Movie]) {
        DispatchQueue.main.async {
            self.movies = movies
            self.collectionView?.reloadData()
        }
    }
    
    
    // Head to Watch List if button tapped
    @IBAction func watchListButtonTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: toWatchList, sender: nil)
    }
    
    // Head to Online Users if button tapped
    @objc func userCountButtonDidTouch() {
        performSegue(withIdentifier: toOnlineUsers, sender: nil)
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return movies.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MoviePhotoCell
        
        // Get photo for every movie
        let moviePhoto = movies[(indexPath as IndexPath).row]
        MovieController.shared.fetchImage(url: URL(string: moviePhoto.imgUrl)! ) { (image) in
            guard let image = image else { return }
            DispatchQueue.main.async {
                cell.imageView.image = image
            }
        }
        cell.backgroundColor = UIColor.black
        
        return cell
    }


    // Head to detail page of selected movie
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailMovie" {
            let detailMovieViewController = segue.destination as! DetailMovieViewController
            let indexPath = self.collectionView?.indexPath(for: sender as! UICollectionViewCell)
            detailMovieViewController.movie = movies[(indexPath?.row)!]
        }
    }

}


// Create the layout for our collectionView
extension MoviesCollectionViewController : UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let paddingSpace = 9 * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem * 1.5)
    }

    // Spacing to sides of screen
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }

    // Spacing between rows
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}
