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
    
    let mGroups: [String] = ["Chest", "Back", "Buttocks", "Lower legs", "Arms", "Upper legs", "Shoulders"]
    var percentages: [Double] {
        var counts = [String: Int]()
        for exercise in workout.exercises {
            counts[exercise.muscle_group, default: 0] += 1
        }
        return mGroups.map { group in
            let count = counts[group] ?? 0
            return workout.exercises.count > 0 ? Double(count) / Double(workout.exercises.count) : 0
        }
    }
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
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
            VStack {
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
                
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(Array(zip(mGroups, percentages)), id: \.0) { group, percentage in
                        
                        VStack(spacing: 2) {
                            Text(group)
                                .font(.system(size: 15))
                                .foregroundColor(.white)
                            
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color("TabBar"))
                                        .frame(width: geometry.size.width, height: 8)
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color("TitleColor"))
                                        .frame(width: geometry.size.width * CGFloat(percentage), height: 8)
                                }
                            }
                            .frame(height: 8)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                ZStack {
                    Blur()
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding(.horizontal, 25)
                        .padding(.vertical, 20)
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 10) {
                            ForEach(workout.exercises, id: \.self) { exercise in
                                HStack {
                                    Image(exercise.muscle_group)
                                        .frame(width: 30, height: 30)
                                        .scaleEffect(0.1)
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
                    .padding(.horizontal, 30)
                    .frame(width: 300, height: 530)
                    
                    Button {
                        
                    } label: {
                        Image(systemName: "play.fill")
                            .foregroundColor(.white)
                            .scaleEffect(2.2)
                            .frame(width: 80, height: 80)
                            .background(Circle().fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color("PurpleColor"), Color.purple]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            ))
                    }
                    .offset(y: 250)
                }
            }
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
    WorkoutInfo(workout: Workout(icon: "figure.run.treadmill", name: "my workout", user_id: "1", exercises: [Exercise(name: "my exercise", muscle_group: "Chest", is_selected: true, weight: 0, sets: 0, reps: 0)]))
}
