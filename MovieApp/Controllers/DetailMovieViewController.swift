//
//  DetailMovieViewController.swift
//  MovieApp
//
//  Created by Jimi Duiveman on 07-12-17.
//  Copyright © 2017 Jimi Duiveman. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Firebase

class DetailMovieViewController: UIViewController, UINavigationControllerDelegate {

    @IBOutlet weak var movieImage: UIImageView!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var backgroundMovieImage: UIImageView!
    @IBOutlet weak var movieOverview: UILabel!
    @IBOutlet weak var movieVoteAverage: UILabel!
    
    var movies = [Movie]()
    var movie: Movie!
    var inWatchList = false
    var userID = Auth.auth().currentUser?.uid
    
    @IBOutlet weak var watchListButton: UIButton!
    let watchListRef = Database.database().reference(withPath: "watch-list")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getInfo()
        checkDatabase()
    }

    
    func checkDatabase() {
        watchListRef.child(userID!).observeSingleEvent(of: .value) { (snap: DataSnapshot) in
            if snap.exists() {
                if let dict = snap.value as? [String: NSDictionary] {
                    for item in dict {
                        if (item.value as NSDictionary)["original_title"] as! String == self.movie.original_title {
                            self.updateButton()
                            print(self.inWatchList)
                        }
                    }
                }
            }
        }
    }

    
    func updateButton() {
        // If movie already on watch list, button will (display) remove
        if inWatchList {
            watchListButton.backgroundColor = #colorLiteral(red: 0.2284384445, green: 0.5989627731, blue: 1, alpha: 1)
            watchListButton.setTitle("Add to Watch List", for: UIControlState.normal)
            inWatchList = false
        }
        // If movie not on watch list, button will (display) add
        else {
            watchListButton.backgroundColor = UIColor.red
            watchListButton.setTitle("Remove from Watch List", for: UIControlState.normal)
            inWatchList = true
        }
    }
        
    func getInfo() {
        
        // Give information to UIImage and labels
        movieTitle.text = movie.original_title
        movieVoteAverage.text = String( format: "%.1f", movie.vote_average )
        movieOverview.text = movie.overview
        MovieController.shared.fetchImage(url: URL(string:movie.imgUrl)! ) { (image) in
            guard let image = image else { return }
            DispatchQueue.main.async {
                self.movieImage.image = image
                self.backgroundMovieImage.image = image
                
            }
        }
        // Blur backgroundImage
        let darkBlur = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurView = UIVisualEffectView(effect: darkBlur)
        blurView.frame = self.backgroundMovieImage.bounds
        self.backgroundMovieImage.addSubview(blurView)
        
    }
    
    @IBAction func watchListButtonTapped(_ sender: UIButton) {
        
        // Animation when tapped
        UIView.animate(withDuration: 0.3) {
            self.watchListButton.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
            self.watchListButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }
        
        if inWatchList {
            // Remove item from list
            movie.deleteFromFirebase(movie_title: movie.original_title, userID: userID!)
            updateButton()
        }
        else {
            // Add item to list
            movie.saveToFirebase(userID: userID!)
            updateButton()
        }
    }


}

