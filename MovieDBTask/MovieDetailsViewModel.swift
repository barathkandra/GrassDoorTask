//
//  MovieDetailsViewModel.swift
//  MovieDBTask
//
//  Created by apple on 14/05/22.
//

import Foundation
import Combine

class MovieDetailsViewModel: ObservableObject {
    
    @Published var moviesDetails: MovieDetails?
    @Published var canLoadNextPage = false
    @Published var loading = false
    
    var cancellationToken: AnyCancellable? // 2
    init() {
       
    }

}

extension MovieDetailsViewModel {
    // Subscriber implementation
    
    func getMoviesDetails(_ value:String) {
        DispatchQueue.main.async { [weak self] in
            self?.cancellationToken = MovieDB.detailsRequest(value) // 4
                .mapError({ (error) -> Error in
                    print(error)
                    return error
                })
                .sink(receiveCompletion: { _ in },
                      receiveValue: {
                        self?.moviesDetails = $0
                      })
        }
    }
}
