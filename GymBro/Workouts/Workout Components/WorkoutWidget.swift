//
//  WorkoutWidget.swift
//  GymBro
//
//  Created by Stepan Polyakov on 23.01.2025.
//

import SwiftUI

struct WorkoutWidget: View {
    var workout: Workout
    
    @State private var offset: CGFloat = 0
    @State private var opacity: Double = 1.0
    @State private var isSwiped: Bool = false
    @State private var height: CGFloat = 113
    @State private var heightdelete: CGFloat = 76
    
    var onTap: () -> Void
    
    var body: some View {
        ZStack {
            if offset < 0 {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.pink, Color.red]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        Image(systemName: "trash")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .offset(x: 150)
                    )
                    .frame(width: 375, height: heightdelete)
                    .offset(y: 18)
                    .opacity(opacity)
            }
            ZStack() {
                Trapezoid().fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color("PurpleColor"), Color.purple]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                         
                HStack(alignment: .center) {
                    Text(workout.name)
                        .font(.system(size: 25))
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        
                    Image(systemName: "chevron.right")
                        .font(.system(size: 20))
                        .foregroundColor(.white)

                    Spacer()
                    Image(systemName: workout.icon)
                        .font(.system(size: 80))
                        .foregroundColor(.white)
                    }
                    .padding([.leading, .trailing], 16)
            }
            .frame(width: 375, height: height, alignment: .bottom)
            .offset(x: offset)
            .simultaneousGesture(
                DragGesture()
                    .onChanged { gesture in
                        if gesture.translation.width < 0 {
                            offset = gesture.translation.width
                        }
                    }
                    .onEnded { gesture in
                        if abs(gesture.translation.width) > UIScreen.main.bounds.width * 0.6 {
                            withAnimation(.easeOut) {
                                offset = -700
                                opacity = 0.0
                                height = 0
                                heightdelete = 0
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                deleteWorkout(id: workout.id)
                            }
                        } else {
                            withAnimation(.spring()) {
                                offset = 0
                            }
                        }
                    }
            )
            .onTapGesture {
                onTap()
            }
        }
    }
}
