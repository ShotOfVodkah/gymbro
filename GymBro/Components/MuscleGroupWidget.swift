//
//  MuscleGroupWidget.swift
//  GymBro
//
//  Created by Stepan Polyakov on 26.01.2025.
//

import SwiftUI

struct MuscleGroupWidget: View {
    var info: String
    @Binding var array: [Exercise]
    @State private var is_open: Bool = false
    var exercises: [Exercise]
    
    var body: some View {
        VStack() {
            Button {
                withAnimation {
                    self.is_open.toggle()
                }
            } label: {
                ZStack(){
                    BackgroundAnimation().scaleEffect(0.5)
                    HStack() {
                        Image(systemName: info)
                            .font(.system(size: 80))
                            .foregroundColor(Color("TitleColor"))
                        Spacer()
                        Text(info)
                            .font(.system(size: 20))
                            .fontWeight(.medium)
                            .foregroundColor(Color("TitleColor"))
                        Spacer()
                        Image(systemName: "chevron.down")
                            .font(.system(size: 30))
                            .foregroundColor(Color("TitleColor"))
                            .rotationEffect(.degrees(is_open ? 180 : 0))
                    }
                    .padding(.trailing, 15)
                }
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .frame(width: 340, height: 100)
                
            }
            if is_open {
                    VStack(spacing: 20) {
                                    ForEach(exercises.filter { $0.muscle_group == info }) { exercise in
                                        VStack(alignment: .leading, spacing: 10) {
                                            Text(exercise.name)
                                                .font(.headline)
                                                .foregroundColor(Color("TitleColor"))
                                        }
                                        .padding()
                                        .background(Color("TabBar"))
                                        .cornerRadius(20)
                                    }
                    }
                    .padding(.horizontal, 10)
                    .frame(width: 340)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 23))
        .background(Color("Background"))
    }
}

#Preview {
    MuscleGroupWidget(info: "figure.american.football", array: .constant([]), exercises: [Exercise(name: "my exercise", muscle_group: "figure.american.football", is_selected: false, weight: 0, sets: 0, reps: 0)])
}
