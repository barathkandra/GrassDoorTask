//
//  MovieDBAPI.swift
//  MovieDBTask
//
//  Created by Barath K on 13/05/22.
//

import Foundation
import Combine

let baseUrlForImage = "https://image.tmdb.org/t/p"

// 1
enum MovieDB {
    static let apiClient = APIClient()
    static let baseUrl = URL(string: "https://api.themoviedb.org/3/movie")!
}

// 2
enum APIPath: String {
    case popular = "/popular"
    case topRated = "/top_rated"
}

extension MovieDB {
    
    static func request(_ path: APIPath) -> AnyPublisher<MovieResponse, Error> {
        // 3
        guard var components = URLComponents(url: baseUrl.appendingPathComponent(path.rawValue), resolvingAgainstBaseURL: true)
            else { fatalError("Couldn't create URLComponents") }
        components.queryItems = [URLQueryItem(name: "api_key", value: "48b33ec538eb1f545bc72f6dc9894561")] // 4
        let request = URLRequest(url: components.url!)
        
        return apiClient.run(request) // 5
            .map(\.value) // 6
            .eraseToAnyPublisher() // 7
    }
}
