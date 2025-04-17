//
//  TrainingsList.swift
//  GymBro
//
//  Created by Александра Грицаенко on 21.01.25.
//

import SwiftUI
import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreCombineSwift

class TrainingsListViewModel: ObservableObject {
    @Published var search: String = ""
    @Published var selectedWorkout: Workout?
    @Published var showWorkoutInfo: Bool = false
    @Published var isActive: Bool = false
    
    @Published var workouts: [Workout] = []
    
    private var userId: String {
        Auth.auth().currentUser?.uid ?? "mHrAJHl1jtReIegIyJC8JbIxj7f1"
    }

    var filteredWorkouts: [Workout] {
        guard !search.isEmpty else { return workouts }
        return workouts.filter { $0.name.localizedCaseInsensitiveContains(search) }
    }
    
    init() {
        fetchWorkouts()
    }
    
    private func fetchWorkouts() {
        let path = "workouts/\(userId)/workouts_for_id"
        Firestore.firestore().collection(path)
            .getDocuments { [weak self] snapshot, error in
                if let documents = snapshot?.documents {
                    self?.workouts = documents.compactMap { try? $0.data(as: Workout.self) }
                    WatchSessionManager.shared.sendUserWorkouts(self?.workouts ?? [])
                }
            }
    }
    
    func updateWorkouts(_ newWorkouts: [Workout]) {
        self.workouts = newWorkouts
        WatchSessionManager.shared.sendUserWorkouts(newWorkouts)
    }

    func selectWorkout(_ workout: Workout) {
        selectedWorkout = workout
        showWorkoutInfo = true
    }

    func toggleWorkoutBuilder(bar: inout Bool) {
        isActive.toggle()
        bar = !isActive
    }
}


struct TrainingsList: View {
    @StateObject private var viewModel = TrainingsListViewModel()
    @Binding var bar: Bool
    @State private var offset: CGFloat = -400

    var body: some View {
        NavigationStack {
            ZStack {
                mainContent
                    .blur(radius: viewModel.isActive ? 5 : 0)

                if viewModel.isActive {
                    WorkoutBuilder(isActive: $viewModel.isActive, bar: $bar)
                }
            }
            .navigationDestination(isPresented: $viewModel.showWorkoutInfo) {
                if let workout = viewModel.selectedWorkout {
                    WorkoutInfo(viewModel: WorkoutInfoViewModel(workout: workout, isInteractive: 1))

                }
            }
            .offset(x: offset)
            .onAppear {
                withAnimation(.spring()) {
                    offset = 0
                }
            }
        }
    }

    private var mainContent: some View {
        VStack {
            header
            searchField
            workoutList
        }
    }

    private var header: some View {
        HStack {
            Text("Экран 3")
                .font(.system(size: 35))
                .fontWeight(.semibold)
                .foregroundColor(Color("TitleColor"))
            Spacer()
            Button {
                viewModel.toggleWorkoutBuilder(bar: &bar)
            } label: {
                plusButton
            }
        }
        .padding(.horizontal, 20)
    }

    private var plusButton: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color("PurpleColor"), Color.purple]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 50, height: 50)
            Image(systemName: "plus.circle")
                .resizable()
                .frame(width: 35, height: 35)
                .foregroundColor(Color.white)
        }
    }

    private var searchField: some View {
        TextField("Search", text: $viewModel.search)
            .padding(10)
            .background(Color("TabBar"))
            .cornerRadius(20)
            .overlay(RoundedRectangle(cornerRadius: 20)
                .stroke(Color("PurpleColor").opacity(0.6), lineWidth: 3)
            )
            .padding(.horizontal, 20)
            .padding(.bottom, 10)
    }

    private var workoutList: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 30) {
                ForEach(viewModel.filteredWorkouts) { workout in
                    WorkoutWidget(workout: workout) {
                        viewModel.selectWorkout(workout)
                    }
                }
                Spacer().frame(height: 60)
            }
        }
    }
}


#Preview {
    TrainingsList(bar: .constant(true))
}
