//
//  Movie.swift
//  MovieApp
//
//  Created by Jimi Duiveman on 07-12-17.
//  Copyright © 2017 Jimi Duiveman. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase

struct Movie {
    var id: Int
    var original_title: String
    var vote_average: Double
    var imgUrl: String
    var overview: String
    
    init(id: Int, original_title: String, vote_average: Double, imgUrl: String, overview: String) {
        self.id = id
        self.original_title = original_title
        self.vote_average = vote_average
        self.imgUrl = imgUrl
        self.overview = overview
    }
    
    
    
    let moviesRef = Database.database().reference(withPath: "watch-list")
    func saveToFirebase(userID: String ) {
        let dict = ["id": self.id,
                    "original_title": self.original_title,
                    "vote_average": self.vote_average,
                    "imgUrl": self.imgUrl,
                    "overview": self.overview
                    ] as [String : Any]
        
        let thisMoviesRef = moviesRef.child(userID).child(dict["original_title"] as! String)
        thisMoviesRef.setValue(dict)
    }
    
    func deleteFromFirebase(movie_title: String, userID: String) {
        moviesRef.child(userID).child(movie_title).removeValue { error,refer  in
            if error != nil {
                print("Error: \(String(describing: error))")
            }
        }
    }
}


struct Movies {
    let items: [Movie]
}
