//
//  MovieDetailsView.swift
//  MovieDBTask
//
//  Created by Barath K on 13/05/22.
//

import SwiftUI

struct MovieDetailsView: View {
    @Binding var push: Bool
    
    var body: some View {
        ZStack {
            Color.yellow
            Button(action: {
                withAnimation(.easeOut(duration: 0.3)) {
                    self.push.toggle()
                }
            }) {
                Text("POP")
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}


