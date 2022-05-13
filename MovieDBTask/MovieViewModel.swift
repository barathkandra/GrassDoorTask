//
//  HomeViewModel.swift
//  MovieDBTask
//
//  Created by Barath K on 13/05/22.
//

import Foundation
import Combine

class MovieViewModel: ObservableObject {
    
    @Published var movies: [Movie] = []
    @Published var canLoadNextPage = false
    @Published var loading = false
    var currentPage: Int = 1
    
    var cancellationToken: AnyCancellable? // 2
    init() {
        if Reachability.isConnectedToNetwork(){
            getMovies(0) {
            }
        } else {
            fetchFromLocalDB(selection: 0)
        }
    }
    
    func refreshFeeds(_ value: Int,completion: @escaping () -> Void) {
        self.currentPage = 1
        getMovies(value) {
            // Pull to refresh loading immediately so delay manually to show result
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                completion()
            }
        }
    }
    
    func fetchFromLocalDB(selection: Int) {
        DispatchQueue.main.async {
            self.movies =  MovieItems.fetchFeedsWithUserID(pageNo: self.currentPage, type: selection == 0 ? "popular" : "topRated")
        }
    }
}

extension MovieViewModel {
    // Subscriber implementation
    
    func getMovies(_ value:Int, completion:@escaping ()->()) {
        DispatchQueue.main.async { [weak self] in
            self?.cancellationToken = MovieDB.request(value == 0 ? .popular : .topRated) // 4
                .mapError({ (error) -> Error in
                    print(error)
                    return error
                })
                .sink(receiveCompletion: { _ in },
                      receiveValue: {
                        self?.movies = $0.movies
                        MovieItems.insertFeeds(self?.movies ?? [], pageValue: self?.currentPage ?? 1, type: value == 0 ? "popular" : "topRated")
                        completion()
                      })
        }
    }
}


