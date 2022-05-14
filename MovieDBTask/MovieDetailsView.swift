//
//  MovieDetailsView.swift
//  MovieDBTask
//
//  Created by Barath K on 13/05/22.
//

import SwiftUI
import AVKit

struct MovieDetailsView: View {
    @Binding var push: Bool
    var movieDetails: Movie
    
    @ObservedObject var viewModel: MovieDetailsViewModel = MovieDetailsViewModel()

    let videoUrl = URL(fileURLWithPath: Bundle.main.path(forResource: "Pexels Sea", ofType: "mp4")!)
    @State var pushView = false

    var body: some View {
        NavigationView {
            if #available(iOS 14.0, *) {
                VStack {
                    Spacer()
                    HStack {
                        Button(action: {
                            withAnimation(.easeOut(duration: 0.3)) {
                                self.push.toggle()
                            }
                        }) {
                            Text("Back")
                        }
                        Spacer()
                    }
                    VStack(alignment: .leading) {
                        URLImageView(urlString: baseUrlForImage + (viewModel.moviesDetails?.posterPath ?? ""))
                            .frame(height: 200)
                            .padding(.all)
                        Text(viewModel.moviesDetails?.originalTitle ?? "")
                            .lineLimit(nil)
                            .font(.headline)
                        Spacer().frame(height: 4)
                        Text(viewModel.moviesDetails?.overview ?? "")
                            .lineLimit(nil)
                            .font(.subheadline)
                        Spacer()
                        
                    }
                    
                    Button(action: {
                        
                        //In the details Response i not found any video url link so statically loading and play video
                        self.pushView = true
                    }) {
                        Text("Watch Trailer")
                            .frame(width: 100, height: 40, alignment: .center)
                    }
                    
                    NavigationLink(destination: VideoPlayerView(url: videoUrl), isActive: $pushView) {
                        Text("")
                    }.hidden().navigationBarTitle(self.pushView ? "New view" : "default view")
                    Spacer()
                }.onAppear(perform: {
                    viewModel.getMoviesDetails(self.movieDetails.movieId?.description ?? "")
                })
                .navigationTitle("VideoPlayer Samples")
                .navigationBarTitleDisplayMode(.inline)
            } else {
                // Fallback on earlier versions
            }
        }

    }
}

struct VideoPlayerWithOverlayView: View {
    
    let url: URL

    var body: some View {
        if #available(iOS 14.0, *) {
            VideoPlayer(player: AVPlayer(url: url), videoOverlay: {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text("Code sample by ToniDevBlog")
                            .foregroundColor(.white)
                    }
                }.padding()
            }).frame(height: 320)
        } else {
            // Fallback on earlier versions
        }
    }
}
