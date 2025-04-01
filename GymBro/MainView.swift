//
//  MainView.swift
//  GymBro
//
//  Created by Александра Грицаенко on 05/02/2025.
//

import SwiftUI

struct MainView: View {
    
    @State var index = 2
    @State private var isTabVisible = true
    @StateObject var vm = FeedListModel()
    
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
    MainView()
}
