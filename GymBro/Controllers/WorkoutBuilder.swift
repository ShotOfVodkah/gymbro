//
//  WorkoutBuilder.swift
//  GymBro
//
//  Created by Stepan Polyakov on 25.01.2025.
//

import SwiftUI

struct WorkoutBuilder: View {
    @Binding var isActive: Bool
    @Binding var bar: Bool
    @State private var offset: CGFloat = 1000
    @State private var opacity: Double = 0
    var body: some View {
        ZStack {
            Blur().edgesIgnoringSafeArea(.all)
                .opacity(opacity) 
            ZStack(alignment: .top) {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color("TabBar"))
                    .frame(width: 375, height: 650)
                Trapezoid()
                    .fill(LinearGradient(gradient: Gradient(colors: [Color("PurpleColor"), Color.purple]),startPoint: .leading,endPoint: .trailing))
                    .frame(width: 375, height: 150)
                    .scaleEffect(x: 1, y: -1)
                VStack(spacing: 0){
                    HStack() {
                        Text("Новая тренировка")
                            .font(.system(size: 35))
                            .fontWeight(.bold)
                            .padding([.top, .leading], 15)
                            .foregroundColor(.white)
                        Spacer()
                        Button {
                            close()
                        } label: {
                            Image(systemName: "xmark").resizable()
                                .frame(width: 20, height: 20)
                        }
                        .tint(.white)
                        .padding([.top, .trailing], 15)
                    }
                    Text("Choose the exercises for your workout")
                        .font(.system(size: 25))
                        .padding(.leading, 15)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                }
            }
            .frame(width: 375, height: 600)
            .offset(y: offset)
            .onAppear {
                withAnimation(.spring()) {
                    offset = 0
                }
                withAnimation(.easeIn(duration: 0.5)) {
                    opacity = 1
                }
            }
        }
    }
    
    func close() {
        withAnimation(.spring()) {
            offset = 750
            isActive = false
            bar = true
        }
        withAnimation(.easeOut(duration: 0.5)) {
            opacity = 0
        }
    }
}

#Preview {
    WorkoutBuilder(isActive: .constant(true), bar: .constant(false))
}
