//
//  WorkoutInfo.swift
//  GymBro
//
//  Created by Stepan Polyakov on 26.01.2025.
//

import SwiftUI

struct WorkoutInfo: View {
    @State private var opacity: Double = 0
    @Environment(\.dismiss) private var dismiss
    var workout: Workout
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color("TabBar").ignoresSafeArea(edges: .all)
                .opacity(opacity)
            VStack(){
                Circle()
                    .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color("PurpleColor"), Color.purple]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    .offset(x: 0, y: 300)
                    .frame(width: 600, height: 600)
                Circle()
                    .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color("PurpleColor"), Color.purple]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    .offset(x: 190, y: 300)
                    .frame(width: 200, height: 200)
                Circle()
                    .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color("PurpleColor"), Color.purple]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    .offset(x: -250, y: 200)
                    .frame(width: 200, height: 200)
                Circle()
                    .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color("PurpleColor"), Color.purple]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    .offset(x: 50, y: 200)
                    .frame(width: 200, height: 200)
            }
            .frame(width: UIScreen.main.bounds.width, height: 100)
            .opacity(opacity)
            ZStack {
                Blur()
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(.horizontal, 25)
                    .padding(.vertical, 120)
                    .offset(y: 100)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 10) {
                        ForEach(workout.exercises, id: \.self) { exercise in
                            HStack {
                                Image(systemName: exercise.muscle_group)
                                    .scaleEffect(1.5)
                                    .padding(.trailing, 10)
                                Text(exercise.name)
                                    .font(.system(size: 25))
                            }
                            .frame(width: 300)
                            .padding()
                            .background(Color("Background").opacity(0.9))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .foregroundColor(Color("TitleColor"))
                        }
                    }
                    .padding()
                }
                .offset(y: 84)
                .padding(.horizontal, 30)
                .frame(width: 300, height: 600)
            }
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                    
                }
                .padding(.leading, 30)
                Spacer()
                Text(workout.name)
                    .font(.system(size: 25))
                    .fontWeight(.semibold)
                    .padding(.trailing, 60)
                    .foregroundColor(.white)
                
                Spacer()
            }
            .padding(.top, 65)
            
            
        }
        .ignoresSafeArea(edges: .all)
        .background(Color("TabBar").opacity(opacity))
        .onAppear {
            withAnimation(.easeIn(duration: 0.5)) {
                opacity = 1
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    WorkoutInfo(workout: Workout(icon: "figure.run.treadmill", name: "my workout", user_id: "1", exercises: [Exercise(name: "my exercise", muscle_group: "figure.american.football", is_selected: true, weight: 0, sets: 0, reps: 0)]))
}
