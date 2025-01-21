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
        ZStack {
            Color.white.ignoresSafeArea()

            VStack {
                Spacer()

                Tab(index: $index)
                    .background(Color("TabBar").ignoresSafeArea(.all, edges: .bottom))
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
                    Image(systemName: "tray.full.fill")
                        .resizable()
                        .frame(width: 25, height: 25)
                }
                .foregroundColor(self.index == 0 ? Color("PurpleColor") : Color.gray)

                Spacer()

                Button(action: {
                    self.index = 1
                }) {
                    Image(systemName: "globe")
                        .resizable()
                        .frame(width: 25, height: 25)
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
                .offset(y: -20)

                Spacer(minLength: geometry.size.width * 0.01)

                Button(action: {
                    self.index = 3
                }) {
                    Image(systemName: "globe")
                        .resizable()
                        .frame(width: 25, height: 25)
                }
                .foregroundColor(self.index == 3 ? Color("PurpleColor") : Color.gray)

                Spacer()

                Button(action: {
                    self.index = 4
                }) {
                    Image(systemName: "globe")
                        .resizable()
                        .frame(width: 25, height: 25)
                }
                .foregroundColor(self.index == 4 ? Color("PurpleColor") : Color.gray)
            }
            .padding(.horizontal, 25)
            .frame(height: 60)
            .background(Color("TabBar"))
        }
        .frame(height: 50)
    }
}
