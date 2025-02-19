//
//  WorkoutPlayer.swift
//  GymBro
//
//  Created by Stepan Polyakov on 16.02.2025.
//

import SwiftUI

struct WorkoutPlayer: View {
    @Binding var workout: Workout;
    @State private var selected: Int = 0;
    @Environment(\.dismiss) private var dismiss
    
    @State private var time = 0.0
    @State private var timer: Timer?
    
    
    var body: some View {
        ZStack {
            Color("Background").ignoresSafeArea()
            GradientAnimation()
            VStack {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                        
                    }
                    .padding(.leading, 20)
                    
                    Spacer()
                    Text(workout.name)
                        .font(.system(size: 30))
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.trailing, 50)
                        .padding(.vertical, 10)
                    
                    Spacer()
                }
                .padding(.horizontal, 10)
                
                
                
                TabView(selection: $selected) {
                    ForEach(0 ..< workout.exercises.count, id: \.self) { index in
                        ExercisePlayWidget(exercise: $workout.exercises[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                HStack {
                    
                    Text(formattedTime(time))
                        .monospacedDigit()
                        .font(.system(size: 22))
                        .fontWeight(.medium)
                        .foregroundColor(Color("TitleColor"))
                        .padding(.leading, 20)
                    
                    ProgressBar(value: CGFloat(selected + 1), total: CGFloat(workout.exercises.count))
                            .frame(height: 10)
                            .padding(.leading, 5)
                            .padding(.trailing, 20)
                            .padding(.vertical, 20)
                }
                .onAppear{
                    timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                        time += 1
                    }
                }
                .onDisappear {
                    timer?.invalidate()
                }
                .background(Color("TabBar").opacity(0.9))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal, 10)
            }
        }
        .navigationBarHidden(true)
    }
    
    private func formattedTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct ProgressBar: View {
    var value: CGFloat
    var total: CGFloat

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .foregroundColor(Color.gray.opacity(0.3))
                
                Rectangle()
                    .frame(width: min(CGFloat(value / total) * geometry.size.width, geometry.size.width), height: geometry.size.height)
                    .foregroundStyle(LinearGradient(
                        gradient: Gradient(colors: [Color("PurpleColor"), Color.purple]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                    .animation(.easeInOut(duration: 0.2), value: value)
            }
            .cornerRadius(5.0)
        }
    }
}

#Preview {
    WorkoutPlayer(workout: .constant(Workout(id: "1" ,icon: "figure.run.treadmill", name: "my workout", user_id: "1", exercises: [Exercise(name: "my exercise", muscle_group: "Chest", is_selected: true, weight: 12, sets: 0, reps: 0), Exercise(name: "other exercise", muscle_group: "Arms", is_selected: true, weight: 20, sets: 0, reps: 0)])))
}
