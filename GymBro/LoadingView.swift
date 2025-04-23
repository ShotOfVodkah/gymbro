//
//  LoadingView.swift
//  GymBro
//
//  Created by Александра Грицаенко on 23/04/2025.
//

import SwiftUI

struct LoadingView: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            Color("Background").ignoresSafeArea()
            VStack {
                Image("GymBro")
                    .resizable()
                    .frame(width: 200, height: 200)
                    .scaleEffect(animate ? 1.0 : 0.7)
                    .opacity(animate ? 1.0 : 0.0)
                    .animation(.easeOut(duration: 1.2), value: animate)
                
                Text("GymBro")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(Color("PurpleColor"))
                    .opacity(animate ? 1.0 : 0.0)
                    .offset(y: animate ? 0 : 30)
                    .animation(.easeOut(duration: 1.2), value: animate)
                
                Text("One more rep, one more tap...\nLet’s crush those goals like it’s leg day.")
                    .font(.headline)
                    .foregroundColor(Color(.label))
                    .multilineTextAlignment(.center)
                    .opacity(animate ? 1.0 : 0.0)
                    .scaleEffect(animate ? 1.0 : 0.7)
                    .offset(x: animate ? 0 : 200)
                    .animation(.easeOut(duration: 1.4), value: animate)
                    .padding(20)
                
                Text("Train like a beast, track like a nerd.")
                    .font(.headline)
                    .foregroundColor(Color("PurpleColor"))
                    .opacity(animate ? 1.0 : 0.0)
                    .scaleEffect(animate ? 1.0 : 0.7)
                    .offset(x: animate ? 0 : -200)
                    .animation(.easeOut(duration: 1.4), value: animate)
            }
            .offset(y: -40)
        }
        .onAppear {
            animate = true
        }
    }
}

#Preview {
    LoadingView()
}
