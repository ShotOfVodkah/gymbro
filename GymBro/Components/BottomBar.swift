//
//  SwiftUIView.swift
//  GymBro
//
//  Created by Stepan Polyakov on 23.01.2025.
//

import SwiftUI

struct Tab: View {
    @Binding var index: Int
    @Binding var isVisible: Bool

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
                .offset(y: -8)

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
                .offset(y: 12)

                Spacer(minLength: geometry.size.width * 0.01)

                Button(action: {
                    self.index = 2
                }) {
                    Image(systemName: "play.circle.fill")
                        .resizable()
                        .frame(width: 90, height: 90)
                }
                .foregroundColor(self.index == 2 ? Color("PurpleColor") : Color.gray)
                .offset(y: -7)

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
                .offset(y: 12)

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
                .offset(y: -8)
            }
            .padding(.horizontal, 25)
            .frame(height: 130)
            .background(Color("TabBar").clipShape(TabBar()))
            .opacity(isVisible ? 1 : 0)
            .allowsHitTesting(isVisible)
        }
        .frame(height: 95)
    }
}
