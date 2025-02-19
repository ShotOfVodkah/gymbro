//
//  TrainingsList.swift
//  GymBro
//
//  Created by Александра Грицаенко on 21.01.25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreCombineSwift

struct TrainingsList: View {
    @FirestoreQuery(collectionPath: "workouts") var workouts: [Workout]
    
    @State private var offset: CGFloat = -400
    @State private var isActive: Bool = false
    
    @Binding var bar: Bool
    
    @State private var selectedWorkout: Workout?
    @State private var showWorkoutInfo: Bool = false
    
    @State private var search: String = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    HStack {
                        Text("Экран 3")
                            .font(.system(size: 35))
                            .fontWeight(.semibold)
                            .foregroundColor(Color("TitleColor"))
                        Spacer()
                        Button {
                            isActive = true
                            bar = false
                        } label: {
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
                    }
                    .padding(.horizontal, 20)
                    
                    TextField("Search", text: $search)
                        .padding(10)
                        .background(Color("TabBar"))
                        .cornerRadius(20)
                        .overlay(RoundedRectangle(cornerRadius: 20)
                            .stroke(Color("PurpleColor").opacity(0.6), lineWidth: 3)
                        )
                        .padding(.horizontal, 20)
                        .padding(.bottom, 10)
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 30) {
                            ForEach(filtered) { workout in
                                WorkoutWidget(workout: workout,onTap: {
                                            selectedWorkout = workout
                                            showWorkoutInfo = true
                                })
                            }
                            Spacer().frame(height: 60)
                        }
                    }
                }
                .blur(radius: isActive ? 5 : 0)
                
                if isActive {
                    ZStack {
                        WorkoutBuilder(isActive: $isActive, bar: $bar)
                    }
                }
            }
            .navigationDestination(isPresented: $showWorkoutInfo) {
                if let workout = selectedWorkout {
                    WorkoutInfo(workout: workout)
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

    var filtered: [Workout] {
        if search.isEmpty {
            return workouts
        } else {
            return workouts.filter { $0.name.localizedCaseInsensitiveContains(search) }
        }
    }
}

#Preview {
    TrainingsList(bar: .constant(true))
}
