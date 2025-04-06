//
//  WorkoutPlayer.swift
//  GymBro
//
//  Created by Stepan Polyakov on 16.02.2025.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreCombineSwift


struct WorkoutPlayer: View {
    let db = Firestore.firestore()
    
    @Binding var workout: Workout;
    @State private var selected: Int = 0;
    @Environment(\.dismiss) private var dismiss

    @Namespace private var animationNamespace
    @State private var showFinishPopup = false
    
    @State var time = 0.0
    @State private var timer: Timer?
    private var isLastExercise: Bool {
            selected == workout.exercises.count - 1
    }
    @State private var message: String = ""
    
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
                    
                    ZStack {
                        if isLastExercise {
                            Button {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    showFinishPopup = true
                                }
                            } label: {
                                Text("Finish")
                                    .font(.system(size: 22))
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                    .frame(width:268,height:35)
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color("PurpleColor"), Color.purple]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                        .matchedGeometryEffect(id: "background", in: animationNamespace)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 10)
                            }
                            .matchedGeometryEffect(id: "container", in: animationNamespace)
                        } else {
                            ProgressBar(value: CGFloat(selected + 1),
                                      total: CGFloat(workout.exercises.count))
                                .frame(height: 10)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 20)
                                .background(
                                    Color("TabBar").opacity(0.9)
                                        .matchedGeometryEffect(id: "background", in: animationNamespace)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .matchedGeometryEffect(id: "container", in: animationNamespace)
                        }
                    }
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isLastExercise)
                }
                .onAppear{
                    timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                        time += 1
                    }
                }
                .onDisappear {
                    timer?.invalidate()
                }
                .frame(width: 380, height: 50)
                .background(Color("TabBar").opacity(0.9))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal, 10)
            }
            .blur(radius: showFinishPopup ? 3 : 0)
            .animation(.easeInOut, value: showFinishPopup)
            
            if showFinishPopup {
                VStack {
                    ZStack{
                        Trapezoid()
                            .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color("PurpleColor"), Color.purple]),
                                startPoint: .trailing,
                                endPoint: .leading
                            ))
                            .frame(width:420, height:100)
                            .rotationEffect(.degrees(180))
                        Text("You've finished your workout, add a message to your friends before we notify them!")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .padding(.top, 20)
                            .padding(.horizontal, 10)
                            .offset(y: -27)
                    }
                    
                    TextField("", text: $message)
                        .padding(10)
                        .background(Color("TabBar"))
                        .cornerRadius(20)
                        .overlay(RoundedRectangle(cornerRadius: 20)
                            .stroke(Color("PurpleColor").opacity(0.6), lineWidth: 3)
                        )
                        .padding(.horizontal, 20)
                        .padding(.bottom, 10)
                    
                    Button {
                        db.collection("workouts").document(workout.id).updateData(["exercises": workout.exercises.map { exercise in
                            return [
                                "name": exercise.name,
                                "muscle_group": exercise.muscle_group,
                                "is_selected": exercise.is_selected,
                                "weight": exercise.weight,
                                "sets": exercise.sets,
                                "reps": exercise.reps
                            ]
                        }])
                        saveWorkoutDone(workout: workout, comment: message)
                        dismiss()
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 20))
                            .frame(width: 100, height: 50)
                            .background(LinearGradient(
                                gradient: Gradient(colors: [Color("PurpleColor"), Color.purple]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .cornerRadius(20)
                            
                    }
                    .padding(.bottom, 20)
                }
                .background(Color("TabBar"))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(LinearGradient(
                            gradient: Gradient(colors: [Color("PurpleColor"), Color.purple]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ), lineWidth: 7)
                )
                .padding(.horizontal, 100)
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
    WorkoutPlayer(workout: .constant(Workout(id: "1" ,icon: "figure.run.treadmill", name: "my workout", user_id: "1", exercises: [Exercise(name: "other exercise", muscle_group: "Arms", is_selected: true, weight: 20, sets: 0, reps: 0)])))
}
