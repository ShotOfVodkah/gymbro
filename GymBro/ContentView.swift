//
//  ContentView.swift
//  GymBro
//
//  Created by Stepan Polyakov on 18.11.2024.
//

import SwiftUI


struct BackgroundAnimation: View {
    @State private var positions: [CGPoint] = [
        CGPoint(x: 50, y: 800),
        CGPoint(x: 400, y: 500),
        CGPoint(x: 200, y: 200)
    ]
    @State private var directions: [CGSize] = [
        CGSize(width: 1, height: 1),
        CGSize(width: -1, height: 1),
        CGSize(width: 1, height: -1)
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<positions.count, id: \.self) { index in
                    Circle()
                        .fill(Color("BackgroundB"))
                        .frame(width: 300, height: 300)
                        .blur(radius: 100)
                        .position(positions[index])
                        .opacity(0.7)
                }
            }
            .onAppear {
                withAnimation(Animation.linear(duration: 6).repeatForever(autoreverses: true)) {
                    moveBalls(geometry.size)
                }
            }
        }
        .ignoresSafeArea()
    }

    private func moveBalls(_ size: CGSize) {
        for index in positions.indices {
            positions[index].x += directions[index].width * CGFloat.random(in: 50...150)
            positions[index].y += directions[index].height * CGFloat.random(in: 50...150)
            if positions[index].x - 200 / 2 <= 0 || positions[index].x + 200 / 2 >= size.width {
                directions[index].width *= -1
            }
            if positions[index].y - 200 / 2 <= 0 || positions[index].y + 200 / 2 >= size.height {
                directions[index].height *= -1
            }
        }
    }
}

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


struct Tab: View {
    @Binding var index: Int

    var body: some View {
        GeometryReader { geometry in
            HStack {
                Button(action: {
                    self.index = 0
                }) {
                    VStack(spacing: 2){
                        Image(systemName: "tray.circle.fill")
                            .resizable()
                            .frame(width: 35, height: 35)
                        
                        Text("Feeds")
                            .font(.system(size: 10))
                    }
                }
                .foregroundColor(self.index == 0 ? Color("PurpleColor") : Color.gray)

                Spacer()

                Button(action: {
                    self.index = 1
                }) {
                    VStack(spacing: 2){
                        Image(systemName: "figure.2.circle.fill")
                            .resizable()
                            .frame(width: 35, height: 35)
                        
                        Text("Team")
                            .font(.system(size: 10))
                    }
                }
                .foregroundColor(self.index == 1 ? Color("PurpleColor") : Color.gray)

                Spacer(minLength: geometry.size.width * 0.01)

                Button(action: {
                    self.index = 2
                }) {
                    Image(systemName: "play.circle.fill")
                        .resizable()
                        .frame(width: 70, height: 70)
                }
                .foregroundColor(self.index == 2 ? Color("PurpleColor") : Color.gray)
                .offset(y: -15)

                Spacer(minLength: geometry.size.width * 0.01)

                Button(action: {
                    self.index = 3
                }) {
                    VStack(spacing: 2){
                        Image(systemName: "figure.run.circle.fill")
                            .resizable()
                            .frame(width: 35, height: 35)
                        
                        Text("Personal")
                            .font(.system(size: 10))
                    }
                }
                .foregroundColor(self.index == 3 ? Color("PurpleColor") : Color.gray)

                Spacer()

                Button(action: {
                    self.index = 4
                }) {
                    VStack(spacing: 2){
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 35, height: 35)
                        
                        Text("Account")
                            .font(.system(size: 10))
                    }
                }
                .foregroundColor(self.index == 4 ? Color("PurpleColor") : Color.gray)
            }
            .padding(.horizontal, 25)
            .frame(height: 60)
            .background(Color("TabBar").opacity(0.4))
        }
        .frame(height: 50)
    }
}
