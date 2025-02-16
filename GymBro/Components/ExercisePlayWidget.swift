//
//  ExercisePlayWidget.swift
//  GymBro
//
//  Created by Stepan Polyakov on 16.02.2025.
//

import SwiftUI

struct ExercisePlayWidget: View {
    @Binding var exercise: Exercise
    @State var rotation: CGFloat = 0.0
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color("TabBar"))
                .frame(width: 350, height: 600)
            RoundedRectangle(cornerRadius: 20)
                .foregroundStyle(LinearGradient(
                    gradient: Gradient(colors: [Color("PurpleColor"), Color.purple]),
                    startPoint: .top,
                    endPoint: .bottom
                ))
                .frame(width: 200, height: 700)
                .rotationEffect(.degrees(rotation))
                .mask {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(lineWidth: 8)
                        .frame(width: 340, height: 590)
                }
            VStack {
                Text(exercise.name)
                    .font(.system(size: 40))
                    .fontWeight(.medium)
                    .foregroundColor(Color("TitleColor"))
                Image(exercise.muscle_group)
                    .scaleEffect(0.7)
                    .frame(height: 150)
                    .shadow(color: .purple.opacity(0.8), radius: 10, x: 0, y: 5)
                    .padding(.bottom, 70)
                    .padding(.top, 30)
                HStack {
                    Spacer()
                    VStack {
                        Text("Sets")
                            .font(.system(size: 25))
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                        Text("\(exercise.sets)")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(LinearGradient(
                        gradient: Gradient(colors: [Color("PurpleColor"), Color.purple]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    Spacer()
                    VStack {
                        Text("Reps")
                            .font(.system(size: 25))
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                        Text("\(exercise.reps)")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 22)
                    .padding(.vertical, 10)
                    .background(LinearGradient(
                        gradient: Gradient(colors: [Color("PurpleColor"), Color.purple]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    Spacer()
                    VStack {
                        Text("Weight")
                            .font(.system(size: 25))
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                        Text("\(exercise.weight)")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 10)
                    .background(LinearGradient(
                        gradient: Gradient(colors: [Color("PurpleColor"), Color.purple]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    Spacer()
                }
                .padding(.bottom, 10)
                Text("Adjust your weights")
                    .font(.system(size: 25))
                    .fontWeight(.medium)
                    .foregroundColor(Color("TitleColor"))
                ScrollViewReader { scrollViewProxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(0...150, id: \.self) { number in
                                Button(action: {
                                    exercise.weight = number
                                    withAnimation {
                                        scrollViewProxy.scrollTo(number, anchor: .center)
                                    }
                                }) {
                                    Text("\(number)")
                                        .font(.system(size: 25, weight: .bold))
                                        .frame(width: 45, height: 45)
                                        .background(exercise.weight == number ? Color.purple : Color.gray.opacity(0.2))
                                        .foregroundColor(exercise.weight == number ? .white : .purple)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                                .id(number)
                            }
                        }
                        .padding(.horizontal, 10)
                    }
                    .padding(.horizontal, 15)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation {
                                scrollViewProxy.scrollTo(exercise.weight, anchor: .center)
                            }
                        }
                    }
                }
            }
            .frame(width: 350, height: 600)
        }
        .onAppear{
            withAnimation(.linear(duration: 6).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

#Preview {
    ExercisePlayWidget(exercise: .constant(Exercise(name: "my exercise", muscle_group: "Arms", is_selected: true, weight: 20, sets: 5, reps: 15)))
}
