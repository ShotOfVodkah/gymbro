//
//  WorkoutCard.swift
//  GymBro
//
//  Created by Stepan Polyakov on 13.04.2025.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseFirestore

struct WorkoutCard: View {
    @Binding var selectedDate: [WorkoutDone]
    var userMap: [String: String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(selectedDate) { workout in
                        NavigationLink {
                            WorkoutInfo(workout: workout.workout, isInteractive: 2)
                        } label: {
                            HStack {
                                Image(systemName: workout.workout.icon)
                                    .font(.system(size: 30))
                                    .foregroundColor(.white)
                                    .padding(.leading,20)
                                Text(workout.workout.name)
                                    .foregroundColor(.white)
                                    .font(.system(size: 20))
                                    .bold()
                                Spacer()
                                if let userName = userMap[workout.workout.user_id] {
                                        Text(userName)
                                            .foregroundColor(.white)
                                            .font(.system(size: 18))
                                            .padding(.trailing, 20)
                                    }
                                
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color("PurpleColor"), Color.purple]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(radius: 4)
                            .padding(.horizontal, 8)
                        }
                    }
                }
                .padding(.vertical, 10)
            }
            .frame(maxHeight: 200)
            .background(Color.white.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal)
            .transition(.opacity.combined(with: .move(edge: .bottom)))
            .animation(.easeInOut, value: selectedDate)
        }
    }
}
