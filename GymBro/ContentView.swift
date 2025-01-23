//
//  ContentView.swift
//  GymBro
//
//  Created by Stepan Polyakov on 18.11.2024.
//

import SwiftUI

struct ContentView: View {
    @State private var index = 2
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("Background").ignoresSafeArea()
                BackgroundAnimation()
                
                VStack {
                    if index == 0 {
                        FeedList()
                    } else if index == 1 {
                        GroupAchievements()
                    } else if index == 2 {
                        TrainingsList()
                    } else if index == 3 {
                        IndividualAchievements()
                    } else if index == 4 {
                        Account()
                    }
                }
                
                VStack {
                    Spacer()
                    Tab(index: $index)
                        .ignoresSafeArea(.all, edges: .bottom)
                }
            }
        }
    }
}


#Preview {
    ContentView()
}

