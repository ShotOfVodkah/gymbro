//
//  WorkoutWidget.swift
//  GymBro
//
//  Created by Stepan Polyakov on 23.01.2025.
//

import SwiftUI

struct WorkoutWidget: View {
    var workout: Workout
    var body: some View {
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
        .frame(width: 375, height: 113, alignment: .bottom)
    }
}

#Preview {
    WorkoutWidget(workout: Workout(icon: "figure.run.treadmill", name: "my workout", user_id: "1", exercises: []))
}
