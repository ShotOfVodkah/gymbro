//
//  Untitled.swift
//  GymBro
//
//  Created by Александра Грицаенко on 02/04/2025.
//

import Foundation
import SwiftUI

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
    
    func placeholder<Content: View> (
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

extension Date {
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.locale = Locale(identifier: "en_US")
        if Int(Date().timeIntervalSince(self)) < 60 {
            return "now"
        }
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}

func getISOWeek(for date: Date) -> String {
    let calendar = Calendar(identifier: .iso8601)
    let year = calendar.component(.yearForWeekOfYear, from: date)
    let week = calendar.component(.weekOfYear, from: date)
    return "\(year)-W\(String(format: "%02d", week))"
}

func getCurrentWeek() -> String {
    return getISOWeek(for: Date())
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
