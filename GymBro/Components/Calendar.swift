//
//  Calendar.swift
//  GymBro
//
//  Created by Stepan Polyakov on 11.04.2025.
//

import Foundation
import SwiftUI

struct CalendarView: View {
    var days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    @State private var currentDate = Date()
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Button{
                    withAnimation {
                        currentDate = Calendar.current.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate
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

                Button{
                    withAnimation {
                        currentDate = Calendar.current.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
                    }
                } label: {
                    Image(systemName: "arrowtriangle.right.fill")
                        .font(.system(size: 25))
                        .foregroundColor(.white)
                        .frame(width: 45, height:45)
                }
            }
            .frame(width:350)
            .background(LinearGradient(
                gradient: Gradient(colors: [Color("PurpleColor"), Color.purple]),
                startPoint: .leading,
                endPoint: .trailing
            ))
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
                ForEach(fetchDates()) { val in
                    ZStack {
                        if val.day != -1 {
                            Circle()
                                .fill(Color("TitleColor").opacity(0.3))
                                .frame(width: 36, height: 36)
                            Text("\(val.day)")
                                .foregroundColor(Color("TitleColor"))
                                .font(.system(size: 16))
                                .fontWeight(.bold)
                        } else {
                            Circle()
                                .fill(Color("TitleColor").opacity(0.1))
                                .frame(width: 36, height: 36)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }

            .frame(width:350, height: 300)
        }
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: date)
    }

    func fetchDates() -> [CalendarDate] {
        var calendar = Calendar.current
        calendar.firstWeekday = 2

        guard let interval = calendar.dateInterval(of: .month, for: currentDate),
              let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate))
        else {
            return []
        }

        let daysInMonth = calendar.dateComponents([.day], from: firstDay, to: interval.end).day ?? 0
        var dates: [CalendarDate] = []

        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay) {
                dates.append(CalendarDate(day: calendar.component(.day, from: date), date: date))
            }
        }

        if let firstDate = dates.first {
            let firstWeekday = calendar.component(.weekday, from: firstDate.date)
            var offset = firstWeekday - calendar.firstWeekday
            if offset < 0 { offset += 7 }

            for _ in 0..<offset {
                dates.insert(CalendarDate(day: -1, date: Date()), at: 0)
            }
        }

        while dates.count < 42 {
            dates.append(CalendarDate(day: -1, date: Date()))
        }

        return dates
    }

}

#Preview {
    CalendarView()
}
