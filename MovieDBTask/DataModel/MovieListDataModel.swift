//
//  MovieListDataModel.swift
//  MovieDBTask
//
//  Created by Barath K on 13/05/22.
//

import Foundation

struct MovieResponse: Codable {
    let movies: [Movie]

    enum CodingKeys: String, CodingKey {
        case movies = "results"
    }
}

struct Movie: Codable, Identifiable {
    
    var id = UUID()
    let movieId: Int?
    let title: String
    let date: String
    let imagePath: String
    let description: String
    enum CodingKeys: String, CodingKey {
        case movieId = "id"
        case title
        case date = "release_date"
        case imagePath = "poster_path"
        case description = "overview"
    }
}
