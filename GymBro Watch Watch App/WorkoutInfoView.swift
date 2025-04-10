//
//  WorkoutInfoView.swift
//  GymBro Watch Watch App
//
//  Created by Stepan Polyakov on 10.04.2025.
//

import SwiftUI

struct WorkoutInfoView: View {
    @State var workout: Workout
    @Environment(\.dismiss) private var dismiss
    @State private var showPlayer = false
    
    var body: some View {
        ZStack(){
            Color("Background").ignoresSafeArea(.all)
            BackgroundAnimation().scaleEffect(0.5)
            VStack(){
                HStack {
                    Button(action: {
                    }) {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 38))
                            .foregroundColor(Color("TitleColor"))
                            .padding(.trailing, 3)
                            .padding(.leading, 10)
                            .padding(.top, 10)
                            .offset(y:-1)
                    }
                    .buttonStyle(PlainButtonStyle())
                    Text(workout.name)
                        .font(.system(size: 17))
                        .fontWeight(.semibold)
                        .foregroundColor(Color("TitleColor"))
                        .offset(y: 5)
                    Spacer()
                }
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 10) {
                        ForEach(workout.exercises, id: \.self) { exercise in
                            HStack {
                                Image(exercise.muscle_group)
                                    .frame(width: 20, height: 20)
                                    .scaleEffect(0.1)
                                    .padding(.trailing, 10)
                                Text(exercise.name)
                                    .font(.system(size: 15))
                            }
                            .frame(width: 180, height: 30)
                            .padding()
                            .background(LinearGradient(
                                gradient: Gradient(colors: [Color("PurpleColor"), Color.purple]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ).opacity(0.9))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .foregroundColor(.white)
                        }
                    }
                    .padding()
                }
                .padding(.horizontal, 30)
                .frame(width: 200, height: 200)
            }
            VStack{
                Spacer()
                Button{
                    showPlayer = true
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 60, height: 60)
                            .shadow(radius: 5)
                            
                        Image(systemName: "play.fill")
                            .foregroundStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color("PurpleColor"), Color.purple]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .font(.system(size: 30))
                    }
                }
                .offset(y: -20)
                .frame(width: 60, height: 60)
            }
        }
        .fullScreenCover(isPresented: $showPlayer) {
            WorkoutPlayerView(workout: $workout)
        }
    }
}
#Preview {
    WorkoutInfoView(workout: Workout(id: "1" ,icon: "figure.run.treadmill", name: "my workout", user_id: "1", exercises: [Exercise(name: "other exercise", muscle_group: "Arms", is_selected: true, weight: 20, sets: 0, reps: 0)]))
}
