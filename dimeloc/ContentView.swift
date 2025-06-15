//
//  ContentView.swift
//  dimeloc
//
//  Created by Maria Martinez on 14/06/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            
            FeedbackListView()
                .tabItem {
                    Image(systemName: "plus.bubble")
                    Text("Feedback")
                }
            
            MapaTiendasView()
                .tabItem {
                    Image(systemName: "map")
                    Text("Mapa")
                }
        }
        .accentColor(.blue)
    }
}

#Preview {
    ContentView()
}
