//
//  VideoPlayerView.swift
//  MovieDBTask
//
//  Created by apple on 14/05/22.
//

import AVKit
import SwiftUI

struct VideoPlayerView: View {
    let url: URL
    var body: some View {
        if #available(iOS 14.0, *) {
            VideoPlayer(player: AVPlayer(url: url))
                .frame(height: 320)
        } else {
            // Fallback on earlier versions
        }
    }
}
