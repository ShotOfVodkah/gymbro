//
//  WorkoutPlayerView.swift
//  GymBro Watch Watch App
//
//  Created by Stepan Polyakov on 10.04.2025.
//

import SwiftUI

struct WorkoutPlayerView: View {
    @Binding var workout: Workout
    @State private var selected: Int = 0
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color("PurpleColor"), Color.purple]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea(.all)
            
            VStack {
                TabView(selection: $selected) {
                    ForEach(0 ..< workout.exercises.count, id: \.self) { index in
                        exerciseCard(index: index)
                            .tag(index)
                    }
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color("TabBar").opacity(0.8))
                            .frame(width: 180, height: 180)
                        
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color("PurpleColor"), Color.purple]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 3
                            )
                            .frame(width: 180, height: 180)
                        
                        VStack {
                            Button(action: {
                                dismiss()
                            }) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 40, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 90, height: 90)
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color("PurpleColor"), Color.purple]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .clipShape(Circle())
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .tag(workout.exercises.count)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .frame(height: 200)
            }
            .padding(.top, 20)
        }
    }
    
    private func exerciseCard(index: Int) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color("TabBar").opacity(0.8))
                .frame(width: 180, height: 180)
            
            RoundedRectangle(cornerRadius: 15)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [Color("PurpleColor"), Color.purple]),
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 3
                )
                .frame(width: 180, height: 180)
            
            VStack {
                Text(workout.exercises[index].name)
                    .font(.system(size: 16))
                    .fontWeight(.medium)
                    .foregroundColor(Color("PurpleColor"))
                    .lineLimit(1)
                    .offset(y: -25)
                
                Image(workout.exercises[index].muscle_group)
                    .scaleEffect(0.3)
                    .frame(height: 40)
                    .shadow(color: .purple.opacity(0.5), radius: 3, x: 0, y: 2)
                
                HStack {
                    VStack {
                        Text("Sets")
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                        Text("\(workout.exercises[index].sets)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .frame(width: 45)
                    .padding(4)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color("PurpleColor"), Color.purple]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    VStack {
                        Text("Reps")
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                        Text("\(workout.exercises[index].reps)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .frame(width: 45)
                    .padding(4)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color("PurpleColor"), Color.purple]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    VStack {
                        Text("Weight")
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                        Text("\(workout.exercises[index].weight)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .frame(width: 45)
                    .padding(4)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color("PurpleColor"), Color.purple]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .offset(y: 25)
            }
            .frame(width: 180, height: 180)
        }
    }
}

#Preview {
    WorkoutPlayerView(workout: .constant(Workout(id: "1" ,icon: "figure.run.treadmill", name: "my workout", user_id: "1", exercises: [Exercise(name: "other exercise", muscle_group: "Arms", is_selected: true, weight: 20, sets: 0, reps: 0), Exercise(name: "other exercise", muscle_group: "Buttocks", is_selected: true, weight: 20, sets: 0, reps: 0)])))
}
