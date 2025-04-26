//
//  Statistics.swift
//  GymBro
//
//  Created by Александра Грицаенко on 08/04/2025.
//

import SwiftUI

struct Statistics: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: StatisticsViewModel

    init(userMap: [String: String]) {
        _viewModel = StateObject(wrappedValue: StatisticsViewModel(userMap: userMap))
    }
    
    var body: some View {
        ZStack {
            BackgroundAnimation()
                .ignoresSafeArea()
            
            NavigationStack {
                VStack {
                    headerView
                    contentView
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    private var headerView: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 30))
                    .foregroundColor(Color("TitleColor"))
            }
            .padding(.leading, 30)
            
            Spacer()
            
            Text("Statistics")
                .font(.system(size: 25, weight: .semibold))
                .foregroundColor(Color("TitleColor"))
                .padding(.trailing, 60)
            
            Spacer()
        }
        .padding(.bottom, 20)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    private var contentView: some View {
        ScrollView {
            VStack(spacing: 16) {
                
                if let stats = viewModel.userStats {
                    StatCard(title: "Total weight lifted",
                        value: "\(stats.totalWeightLifted)",
                        icon: "scalemass.fill")
                                        
                    StatCard(title: "Workouts completed",
                        value: "\(stats.totalWorkoutsDone)",
                        icon: "flame.fill")
                                        
                    StatCard(title: "Exercises done",
                        value: "\(stats.totalExercisesDone)",
                        icon: "dumbbell.fill")
                    
                    WorkoutsChartView(workoutsPerWeek: stats.workoutsPerWeek)
                    
                    MuscleGroupsCard(muscleGroups: stats.topMuscleGroups)
                }
                
                CalendarView(userMap: viewModel.userMap)
                    .padding(.all, 25)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color("TabBar").opacity(0.8))
                    )

            }
            .padding(.horizontal)
        }
        .frame(width: 390)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(Color("TitleColor"))
                .frame(width: 40)
            
            Text(LocalizedStringKey(title))
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color("TitleColor"))
            
            Spacer()
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [Color("PurpleColor"), Color.purple]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                )
            
        }
        .padding(.all, 7)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color("TabBar").opacity(0.8))
        )
    }
}

struct MuscleGroupsCard: View {
    let muscleGroups: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Spacer()
                
                Text(LocalizedStringKey("Top muscle groups"))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color("TitleColor"))
                
                Spacer()
            }
            
            if muscleGroups.isEmpty {
                Text("No data available")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
            } else {
                HStack(spacing: 10) {
                    ForEach(0..<min(muscleGroups.count, 3), id: \.self) { index in
                        VStack {
                            Image(muscleGroups[index])
                                .frame(width:100, height:80)
                                .scaleEffect(0.3)
                                .offset(y: 15)
                            Text(LocalizedStringKey(muscleGroups[index]))
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                        }
                        .frame(width:120, height:120)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(LinearGradient(gradient: Gradient(colors: [Color("PurpleColor"), Color.purple]),
                                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                        )
                    }
                }
            }
        }
        .padding(.all, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color("TabBar").opacity(0.8))
        )
    }
}

struct WorkoutsChartView: View {
    let workoutsPerWeek: [String: Int]
    
    private var maxCount: Int {
        max(workoutsPerWeek.values.max() ?? 0, 5)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Spacer()
                Text(LocalizedStringKey("Workouts per week"))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color("TitleColor"))
                    .padding(.bottom, 8)
                Spacer()
            }
            
            if workoutsPerWeek.isEmpty {
                Text("No workout data")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                GeometryReader { geometry in
                    let width = geometry.size.width
                    let height = geometry.size.height
                    
                    chartGrid(width: width, height: height)
                    chartLine(width: width, height: height)
                    chartPoints(width: width, height: height)
                    axisLabels(width: width, height: height)
                }
                .frame(height: 200)
                .padding(.all, 20)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color("TabBar").opacity(0.8))
        )
    }
    
    private func chartGrid(width: CGFloat, height: CGFloat) -> some View {
        Path { path in
            for i in 0...maxCount {
                let y = height - (height * CGFloat(i) / CGFloat(maxCount))
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: width, y: y))
            }
        }
        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
    }
    
    private func chartLine(width: CGFloat, height: CGFloat) -> some View {
        Path { path in
            guard !workoutsPerWeek.isEmpty else { return }
            
            let stepX = width / CGFloat(workoutsPerWeek.count - 1)
            
            for (index, entry) in workoutsPerWeek.sorted(by: { $0.key < $1.key }).enumerated() {
                let x = CGFloat(index) * stepX
                let y = height - (height * CGFloat(entry.value) / CGFloat(maxCount))
                
                if index == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    let prevEntry = workoutsPerWeek.sorted(by: { $0.key < $1.key })[index - 1]
                    let prevX = CGFloat(index - 1) * stepX
                    let prevY = height - (height * CGFloat(prevEntry.value) / CGFloat(maxCount))
                    
                    let controlX1 = prevX + (x - prevX) * 0.3
                    let controlX2 = prevX + (x - prevX) * 0.7
                    
                    path.addCurve(
                        to: CGPoint(x: x, y: y),
                        control1: CGPoint(x: controlX1, y: prevY),
                        control2: CGPoint(x: controlX2, y: y)
                    )
                }
            }
        }
        .stroke(
            LinearGradient(
                gradient: Gradient(colors: [Color("PurpleColor"), Color.purple]),
                startPoint: .leading,
                endPoint: .trailing
            ),
            style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
        )
    }
    
    private func chartPoints(width: CGFloat, height: CGFloat) -> some View {
        ForEach(Array(workoutsPerWeek.sorted(by: { $0.key < $1.key }).enumerated()), id: \.offset) { index, entry in
            let x = width * CGFloat(index) / CGFloat(workoutsPerWeek.count - 1)
            let y = height - (height * CGFloat(entry.value) / CGFloat(maxCount))
            
            Circle()
                .fill(Color.white)
                .frame(width: 10, height: 10)
                .overlay(
                    Circle()
                        .stroke(Color("PurpleColor"), lineWidth: 2)
                )
                .position(x: x, y: y)
        }
    }
    
    private func axisLabels(width: CGFloat, height: CGFloat) -> some View {
        Group {
            ForEach(0...maxCount, id: \.self) { value in
                let y = height - (height * CGFloat(value) / CGFloat(maxCount))
                
                Text("\(value)")
                    .font(.system(size: 10))
                    .foregroundColor(Color("TitleColor").opacity(0.7))
                    .position(x: -15, y: y)
            }
            
            ForEach(Array(workoutsPerWeek.sorted(by: { $0.key < $1.key }).enumerated()), id: \.offset) { index, entry in
                if index % 4 == 0 || index == workoutsPerWeek.count - 1 {
                    let x = width * CGFloat(index) / CGFloat(workoutsPerWeek.count - 1)
                    
                    Text(entry.key.replacingOccurrences(of: "W", with: ""))
                        .font(.system(size: 10))
                        .foregroundColor(Color("TitleColor").opacity(0.7))
                        .position(x: x, y: height + 15)
                }
            }
        }
    }
}



#Preview {
    Statistics(userMap:  ["g9wEOL71fNeTFlLcEhhzWHua1wK2": "Stepan"])
}

