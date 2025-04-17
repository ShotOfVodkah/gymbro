//
//  WorkoutInfo.swift
//  GymBro
//
//  Created by Stepan Polyakov on 26.01.2025.
//

import SwiftUI
import FirebaseAuth

class WorkoutInfoViewModel: ObservableObject {
    @Published var workout: Workout
    @Published var opacity: Double = 0
    
    let uid = Auth.auth().currentUser?.uid
    let mGroups: [String] = ["Chest", "Back", "Buttocks", "Lower legs", "Arms", "Upper legs", "Shoulders"]
    
    var isInteractive: Int = 1
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
    
    init(workout: Workout, isInteractive: Int = 1) {
        self.workout = workout
        self.isInteractive = isInteractive
    }
    
    func deleteWorkoutAndDismiss(_ dismiss: DismissAction) {
        deleteWorkout(id: workout.id)
        dismiss()
    }
    
    func shouldShowCloneButton() -> Bool {
        return isInteractive == 2 && uid != workout.user_id
    }
}


struct WorkoutInfo: View {
    @StateObject var viewModel: WorkoutInfoViewModel
    @Environment(\.dismiss) private var dismiss
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color("TabBar").ignoresSafeArea().opacity(viewModel.opacity)
            decorativeBackground.opacity(viewModel.opacity)
            
            VStack {
                header
                muscleGroupGrid
                workoutCardSection
            }
        }
        .background(Color("TabBar").opacity(viewModel.opacity))
        .onAppear {
            viewModel.opacity = 1
        }
        .navigationBarHidden(true)
    }
    
    private var header: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 30))
                    .foregroundColor(.white)
            }
            .padding(.leading, 30)
            
            Spacer()
            
            Text(viewModel.workout.name)
                .font(.system(size: 25))
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Spacer()
            
            Button(action: { viewModel.deleteWorkoutAndDismiss(dismiss) }) {
                Image(systemName: "trash")
                    .font(.system(size: 25))
                    .foregroundColor(.white)
            }
            .padding(.trailing, 30)
            .opacity(viewModel.isInteractive == 1 ? 1.0 : 0.0)
            .disabled(!(viewModel.isInteractive == 1))
        }
    }
    
    private var muscleGroupGrid: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(Array(zip(viewModel.mGroups, viewModel.percentages)), id: \.0) { group, percentage in
                VStack(spacing: 2) {
                    Text(LocalizedStringKey(group))
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
    }
    
    private var workoutCardSection: some View {
        ZStack {
            Blur()
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal, 25)
                .padding(.vertical, 20)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 10) {
                    ForEach(viewModel.workout.exercises, id: \.self) { exercise in
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
            
            if viewModel.isInteractive == 1 {
                NavigationLink(destination: WorkoutPlayer(workout: $viewModel.workout)) {
                    playButton
                }
                .offset(y: 250)
            } else if viewModel.shouldShowCloneButton() {
                Button {
                    createWorkout(
                        name: viewModel.workout.name,
                        exercises: viewModel.workout.exercises,
                        icon: viewModel.workout.icon
                    )
                    dismiss()
                } label: {
                    plusButton
                }
                .offset(y: 250)
            }
        }
    }
    
    private var playButton: some View {
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
    
    private var plusButton: some View {
        Image(systemName: "plus")
            .foregroundColor(.white)
            .scaleEffect(3.2)
            .frame(width: 80, height: 80)
            .background(Circle().fill(
                LinearGradient(
                    gradient: Gradient(colors: [Color("PurpleColor"), Color.purple]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            ))
    }
    
    private var decorativeBackground: some View {
        VStack {
            Circle()
                .fill(gradientFill)
                .offset(x: 0, y: 300)
                .frame(width: 600, height: 600)
            Circle()
                .fill(gradientFill)
                .offset(x: 190, y: 300)
                .frame(width: 200, height: 200)
            Circle()
                .fill(gradientFill)
                .offset(x: -250, y: 200)
                .frame(width: 200, height: 200)
            Circle()
                .fill(gradientFill)
                .offset(x: 50, y: 200)
                .frame(width: 200, height: 200)
        }
        .frame(width: UIScreen.main.bounds.width, height: 100)
    }
    
    private var gradientFill: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [Color("PurpleColor"), Color.purple]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}


#Preview {
    WorkoutInfo(viewModel: WorkoutInfoViewModel(workout: Workout(id: "1" ,icon: "figure.run.treadmill", name: "my workout", user_id: "1", exercises: [Exercise(name: "my exercise", muscle_group: "Chest", is_selected: true, weight: 0, sets: 0, reps: 0)]), isInteractive: 1))
}
