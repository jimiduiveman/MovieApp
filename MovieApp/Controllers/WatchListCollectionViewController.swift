//
//  WatchListCollectionViewController.swift
//  MovieApp
//
//  Created by Jimi Duiveman on 09-12-17.
//  Copyright © 2017 Jimi Duiveman. All rights reserved.
//

import UIKit
import FirebaseDatabase

class WatchListCollectionViewController: UICollectionViewController {

    fileprivate let sectionInsets = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
    fileprivate let itemsPerRow: CGFloat = 3
    fileprivate let reuseIdentifier = "watchCell"

    var movies = [Movie]()
    let watchListRef = Database.database().reference(withPath: "watch-list")
    
    
    func loadFromFirebase() {
        self.movies.removeAll()
        watchListRef.observeSingleEvent(of: .value) { (snap: DataSnapshot) in
            if snap.exists() {
                if let dict = snap.value as? [String: NSDictionary] {
                    for item in dict {
                        let original_title = (item.value as NSDictionary)["original_title"] as! String
                        let id = (item.value as NSDictionary)["id"] as! Int
                        let overview = (item.value as NSDictionary)["overview"] as! String
                        let imgUrl = (item.value as NSDictionary)["imgUrl"] as! String
                        let vote_average = (item.value as NSDictionary)["vote_average"] as! Double
    
                        let movie = Movie(id: id, original_title: original_title, vote_average: vote_average, imgUrl: imgUrl, overview: overview)
                        self.movies.append(movie)
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        let myGroup = DispatchGroup()
        myGroup.enter()
        //// Do your task
        loadFromFirebase()
        myGroup.leave() //// When your task completes
        myGroup.notify(queue: DispatchQueue.main) {
            self.collectionView!.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    // MARK: Lay-out

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! watchListMoviePhotoCell
        
        // Get photo for movie
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
    
    //MARK: Segue
    
    // Head to detail page of selected movie
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailPage" {
            let detailMovieViewController = segue.destination as! DetailMovieViewController
            if movies.count > 0 {
                let indexPath = self.collectionView?.indexPath(for: sender as! UICollectionViewCell)
                detailMovieViewController.movie = movies[(indexPath?.row)!]
            }
        }
    }

}

// Create layout of our collectionView
extension WatchListCollectionViewController : UICollectionViewDelegateFlowLayout {
    
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

