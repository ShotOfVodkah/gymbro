//
//  ContentView.swift
//  GymBro
//
//  Created by Stepan Polyakov on 18.11.2024.
//

import SwiftUI

struct ContentView: View {
    @State private var index = 2
    @State private var isTabVisible = true
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("Background").ignoresSafeArea()
                BackgroundAnimation()
                
                VStack {
                    if index == 0 {
                        FeedList(bar: $isTabVisible)
                    } else if index == 1 {
                        GroupAchievements(bar: $isTabVisible)
                    } else if index == 2 {
                        TrainingsList(bar: $isTabVisible)
                    } else if index == 3 {
                        IndividualAchievements(bar: $isTabVisible)
                    } else if index == 4 {
                        Account(bar: $isTabVisible)
                    }
                }
                
                VStack {
                    Spacer()
                    Tab(index: $index, isVisible:  $isTabVisible)
                        .ignoresSafeArea(.all, edges: .bottom)
                }
            }
        }
    }
}


#Preview {
    ContentView()
}

