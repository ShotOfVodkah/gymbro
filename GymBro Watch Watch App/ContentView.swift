//
//  ContentView.swift
//  GymBro Watch Watch App
//
//  Created by Stepan Polyakov on 08.04.2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var dataManager = WatchDataManager.shared
    @State private var selectedWorkout: Workout? = nil
    
    var workouts : [Workout] //убрать
    
    var body: some View {
        ZStack {
            Color("Background").ignoresSafeArea(.all)
            BackgroundAnimation().scaleEffect(0.5)
            VStack {
                Text("My workouts")
                    .font(.system(size: 25))
                    .fontWeight(.semibold)
                    .foregroundColor(Color("TitleColor"))
                    .offset(x: -10)
                ScrollView {
                    VStack(spacing: 1) {
                        ForEach(workouts) { workout in
                            Button {
                                selectedWorkout = workout
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 15).fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color("PurpleColor"), Color.purple]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ))
                                    HStack{
                                        Text(workout.name)
                                            .font(.system(size: 15))
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 20))
                                            .foregroundColor(.white)
                                        
                                    }
                                    .padding([.leading, .trailing], 16)
                                    
                                }
                            }
                            .frame(width:180, height: 60)
                        }
                    }
                }
                .frame(height: 170)
            }
        }
        .sheet(item: $selectedWorkout) { workout in
            WorkoutInfoView(workout: workout)
        }
    }
}



#Preview {
    ContentView(workouts: [Workout(id: "1" ,icon: "figure.run.treadmill", name: "my workout", user_id: "1", exercises: [Exercise(name: "other exercise", muscle_group: "Arms", is_selected: true, weight: 20, sets: 0, reps: 0)]), Workout(id: "2" ,icon: "figure.run.treadmill", name: "Work!", user_id: "1", exercises: [Exercise(name: "other exercise", muscle_group: "Arms", is_selected: true, weight: 20, sets: 0, reps: 0)]), Workout(id: "3" ,icon: "figure.run.treadmill", name: "my workout", user_id: "1", exercises: [Exercise(name: "other exercise", muscle_group: "Arms", is_selected: true, weight: 20, sets: 0, reps: 0), Exercise(name: "other exercise", muscle_group: "Buttocks", is_selected: true, weight: 20, sets: 0, reps: 0)])])
}
