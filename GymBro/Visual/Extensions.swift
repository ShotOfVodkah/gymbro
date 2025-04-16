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

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct settingsButtonView<Destination: View>: View {
    var image = ""
    var name = Text("")
    var destination: Destination
    var body: some View {
        NavigationLink(destination: destination) {
            VStack {
                HStack(spacing: 15) {
                    Image(systemName: image)
                        .font(.system(size: 30))
                        .foregroundColor(Color("TitleColor"))
                    name
                    Spacer(minLength: 15)
                    Image(systemName: "chevron.right")
                }
                .padding()
                .foregroundColor(Color(.label))
                Divider()
                    .padding(.top, -5)
            }
            .padding(.vertical, -5)
            .padding(.horizontal, 10)
        }
    }
}

struct SettingsButtonActionView: View {
    var image: String = ""
    var name: Text = Text("")
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack {
                HStack(spacing: 15) {
                    Image(systemName: image)
                        .font(.system(size: 30))
                        .foregroundColor(Color("TitleColor"))
                    name
                    Spacer(minLength: 15)
                }
                .padding()
                .foregroundColor(Color(.label))
                Divider()
                    .padding(.top, -5)
            }
            .padding(.vertical, -5)
            .padding(.horizontal, 10)
        }
    }
}

struct InfoField: View {
    var title = Text("")
    var isNumber: Bool
    @Binding var text: String
    @FocusState var isTyping: Bool
    
    var body: some View {
        ZStack(alignment: .leading) {
            TextField("", text: $text).padding(.leading)
                .frame(height: 55).focused($isTyping)
                .keyboardType(isNumber ? .decimalPad : .default)
                .background(isTyping ? Color("PurpleColor") : Color(.systemGray), in: RoundedRectangle(cornerRadius: 14).stroke(lineWidth: 1))
            title.padding(.horizontal, 5)
                .background(Color("Background").opacity(isTyping || !text.isEmpty ? 1 : 0))
                .foregroundStyle((!text.isEmpty && !isTyping) || isTyping ? Color("PurpleColor") : Color.primary)
                .padding(.leading).offset(x: isTyping || !text.isEmpty ? 10 : 0,
                                          y: isTyping || !text.isEmpty ? -28 : 0)
                .onTapGesture {
                    isTyping.toggle()
                }
        }
        .animation(.linear(duration: 0.1), value: isTyping)
        .padding(.vertical, 5)
    }
}

struct GenderPickerField: View {
    var title = Text("")
    @Binding var selectedGender: String
    var shouldShowArrow: Bool
    let genders = ["Male", "Female", "Other"]
    @State private var isExpanded = false
    
    var body: some View {
        ZStack(alignment: .leading) {
            HStack {
                Text(selectedGender)
                    .foregroundColor(.primary)
                Spacer()
                if shouldShowArrow {
                    Image(systemName: "chevron.down")
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
            }
            .padding()
            .frame(height: 55)
            .background(RoundedRectangle(cornerRadius: 14)
                .stroke(isExpanded ? Color("PurpleColor") : Color(.systemGray), lineWidth: 1))
            .onTapGesture {withAnimation(.spring()) {isExpanded.toggle()}}
            
            title.padding(.horizontal, 5)
                .background(Color("Background").opacity(isExpanded || !selectedGender.isEmpty ? 1 : 0))
                .foregroundStyle(!selectedGender.isEmpty ? Color("PurpleColor") : Color.primary)
                .padding(.leading).offset(x: isExpanded || !selectedGender.isEmpty ? 10 : 0,
                                          y: isExpanded || !selectedGender.isEmpty ? -28 : 0)
            
            if isExpanded {
                VStack(spacing: 0) {
                    ForEach(genders, id: \.self) { gender in
                        Button(action: {withAnimation(.spring()) {
                            selectedGender = gender
                            isExpanded = false
                        }}) {
                            HStack {
                                Text(gender)
                                    .foregroundColor(.white)
                                Spacer()
                                if selectedGender == gender {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.white)
                                }
                            }
                            .padding()
                            .frame(height: 44)
                        }
                        Divider()
                    }
                }
                .background(Color("PurpleColor"))
                .cornerRadius(14)
                .zIndex(1)
            }
        }
        .animation(.spring(), value: isExpanded)
        .padding(.vertical, 5)
    }
}
