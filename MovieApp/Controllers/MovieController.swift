//
//  MovieController.swift
//  MovieApp
//
//  Created by Jimi Duiveman on 07-12-17.
//  Copyright © 2017 Jimi Duiveman. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase

class MovieController {
    
    static let shared = MovieController()
    
    func fetchMovieItems(completion: @escaping ([Movie]?) -> Void) {
        var movies = [Movie]()
        
        // Assign API
        let url = "https://api.themoviedb.org/3/movie/popular?api_key=5fae35f98231db5bf0c6d99e4b5a8678&language=en-US&page=1"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = ("GET")
        
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: nil, delegateQueue: OperationQueue.main )
        
        // First page with popular movies
        let task = session.dataTask(with: request) { (data, repsonse, error) in
            if error != nil {
                print("Error ")
            }
            else {
                do {
                    
                    // Get data
                    let fetchedData = try JSONSerialization.jsonObject(with: data!, options: .mutableLeaves) as! NSDictionary
                    for eachFetchedMovie in fetchedData["results"]! as! NSArray {
                        let eachMovie = eachFetchedMovie as! [String: Any]
                        let original_title = eachMovie["original_title"] as! String
                        let vote_average = eachMovie["vote_average"] as! NSNumber
                        let poster_path = eachMovie["poster_path"] as! String
                        let imgUrl = "https://image.tmdb.org/t/p/w780" + poster_path
                        let overview = eachMovie["overview"] as! String
                        let id = eachMovie["id"] as! Int
                        
                        movies.append(Movie(id: id, original_title: original_title, vote_average: vote_average as! Double, imgUrl: imgUrl, overview: overview))
                        completion(movies)
                    }
                }
                catch {
                    print("Error")
                }
            }
        }
        task.resume()
    }
    
    func fetchImage(url: URL, completion: @escaping (UIImage?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data,
                let image = UIImage(data: data) { 
                completion(image)
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
    
    var watchListMovies = [Movie]()
}
