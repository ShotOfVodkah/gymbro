//
//  Calendar.swift
//  GymBro
//
//  Created by Stepan Polyakov on 11.04.2025.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseFirestore

struct CalendarView: View {
    var days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    @State private var currentDate = Date()
    
    var userMap: [String: String]
    
    @StateObject private var viewModel = CalendarViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 15) {
                HStack {
                    Button {
                        withAnimation {
                            currentDate = Calendar.current.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate
                            Task {
                                await viewModel.fetchDates(for: currentDate, userMap: userMap)
                            }
                        }
                    } label: {
                        Image(systemName: "arrowtriangle.backward.fill")
                            .font(.system(size: 25))
                            .foregroundColor(.white)
                            .frame(width: 45, height:45)
                    }

                    Text(formattedDate(currentDate))
                        .foregroundColor(.white)
                        .font(.system(size: 20))
                        .fontWeight(.medium)
                        .frame(width: 150)

                    Button {
                        withAnimation {
                            currentDate = Calendar.current.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
                            Task {
                                await viewModel.fetchDates(for: currentDate, userMap: userMap)
                            }
                        }
                    } label: {
                        Image(systemName: "arrowtriangle.right.fill")
                            .font(.system(size: 25))
                            .foregroundColor(.white)
                            .frame(width: 45, height:45)
                    }
                }
                .frame(width:350)
                .background(LinearGradient(gradient: Gradient(colors: [Color("PurpleColor"), Color.purple]), startPoint: .leading, endPoint: .trailing))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                
                HStack {
                    ForEach(days, id: \.self) { day in
                        Text(LocalizedStringKey(day))
                            .font(.system(size: 15, weight: .medium))
                            .frame(width: 43)
                            .foregroundStyle(Color("TitleColor"))
                    }
                }

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 15) {
                    ForEach(viewModel.calendarDates) { val in
                        ZStack {
                            if val.day != -1 {
                                if !val.workouts.isEmpty {
                                    Button {
                                        viewModel.selectedDate = val.workouts
                                    } label: {
                                        Text("\(val.day)")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(.white)
                                            .frame(width: 36, height: 36)
                                            .background(
                                                LinearGradient(colors: [Color("PurpleColor"), Color.purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                                            )
                                            .clipShape(Circle())
                                    }
                                } else {
                                    Circle()
                                        .fill(Color("TitleColor").opacity(0.3))
                                        .frame(width: 36, height: 36)
                                    Text("\(val.day)")
                                        .foregroundColor(Color("TitleColor"))
                                        .font(.system(size: 16))
                                        .fontWeight(.bold)
                                }
                            } else {
                                Circle()
                                    .fill(Color("TitleColor").opacity(0.1))
                                    .frame(width: 36, height: 36)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(width: 350, height: 300)
                
                if !viewModel.selectedDate.isEmpty {
                    WorkoutCard(selectedDate: $viewModel.selectedDate, userMap: userMap)
                }
            }
            .task {
                await viewModel.fetchDates(for: currentDate, userMap: userMap)
            }
        }
    }

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: date)
    }
}

#Preview {
    CalendarView(userMap: ["mHrAJHl1jtReIegIyJC8JbIxj7f1":"Alexandra", "nwsy9PklqCb56PrRMnDWuw0195f1":"Stepan"])
}
