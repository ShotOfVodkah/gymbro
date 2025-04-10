//
//  WorkOutHistory.swift
//  GymBro
//
//  Created by Александра Грицаенко on 08/04/2025.
//

import SwiftUI

struct WorkoutHistory: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var vm = WorkoutHistoryModel()
    @State private var showWorkoutInfo: Bool = false
    @State private var selectedWorkout: Workout?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("Background").ignoresSafeArea()
                BackgroundAnimation()

                ScrollView {
                    ForEach(vm.doneWorkouts) { doneWorkout in
                        VStack {
                            Button {
                                selectedWorkout = doneWorkout.workout
                                showWorkoutInfo = true
                            } label: {
                                HStack(spacing: 15) {
                                    Image(systemName: doneWorkout.workout.icon)
                                        .font(.system(size: 40))
                                        .padding(5)
                                        .foregroundColor(Color(.label))
                                    VStack(alignment: .leading) {
                                        Text(doneWorkout.workout.name)
                                            .font(.system(size: 15, weight: .bold))
                                            .foregroundColor(Color("PurpleColor"))
                                        Text(doneWorkout.comment.isEmpty ? "-" : doneWorkout.comment)
                                            .font(.system(size: 15))
                                            .foregroundColor(Color(.label))
                                            .lineLimit(2)
                                            .multilineTextAlignment(.leading)
                                        Text(doneWorkout.timestamp.formatted(.dateTime))
                                            .font(.system(size: 15))
                                            .foregroundColor(Color(.label))
                                    }
                                    Spacer()
                                    Text(doneWorkout.timestamp.timeAgoDisplay())
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(Color("PurpleColor"))
                                }
                                .padding(.horizontal)
                            }
                            Divider()
                                .padding(.vertical, 5)
                        }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Workout History")
                            .font(.system(size: 30))
                            .fontWeight(.semibold)
                            .foregroundColor(Color("TitleColor"))
                    }
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            Text("Cancel")
                                .font(.system(size: 20))
                                .foregroundColor(Color("TitleColor"))
                        }
                    }
                }
                .navigationDestination(isPresented: $showWorkoutInfo) {
                    if let workout = selectedWorkout {
                        WorkoutInfo(workout: workout)
                    }
                }
            }
        }
    }
}

#Preview {
    WorkoutHistory()
}
