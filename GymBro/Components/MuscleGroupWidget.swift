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
    @Binding var exercises: [Exercise]
    
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
                VStack(spacing: 10) {
                    ForEach(exercises.indices.filter { exercises[$0].muscle_group == info }, id: \.self) { index in
                        ExerciseWidget(array: $array, exercise: $exercises[index])
                    }
                }
                .padding(.bottom, 10)
                .padding(.horizontal, 10)
                .frame(width: 340)
            }
        }
        .background(Color("Background"))
        .clipShape(RoundedRectangle(cornerRadius: 23))
    }
}

struct ExerciseWidget: View {
    @Binding var array: [Exercise]
    @Binding var exercise: Exercise
    var body: some View {
        ZStack{
            VStack {
                Button() {
                    withAnimation {
                        self.exercise.is_selected.toggle()
                        if exercise.is_selected {
                            array.append(exercise)
                        } else {
                            if let index = array.firstIndex(where: { $0.id == exercise.id }) {
                                array.remove(at: index)
                            }
                        }
                    }
                } label: {
                    Spacer()
                    Text(exercise.name)
                        .font(.system(size: 20))
                        .fontWeight(exercise.is_selected ? .semibold : .medium)
                        .foregroundColor(Color("TitleColor"))
                        .padding(.leading, 40)
                    Spacer()
                    Image(systemName:  "checkmark.circle.fill")
                        .font(.system(size: 30))
                        .padding(.trailing, 10)
                        .foregroundStyle(LinearGradient(
                            gradient: Gradient(colors: [Color("PurpleColor"), Color.purple]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .opacity(exercise.is_selected ? 1 : 0)
                }
                .frame(width: 320, height: 50)
                .background(Color("TabBar"))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                if (exercise.is_selected) {
                    HStack{
                        Text("Sets")
                            .fontWeight(.medium)
                            .foregroundColor(Color("TitleColor"))
                            .padding(.leading, 10)
                        Spacer()
                        NumberToggle(range: 7, res: $exercise.sets)
                            .background(Color("Background"))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .frame(width: 230)
                            .padding(.trailing, 10)
                    }
                    .frame(width: 320)
                    HStack{
                        Text("Reps")
                            .fontWeight(.medium)
                            .foregroundColor(Color("TitleColor"))
                            .padding(.leading, 10)
                        Spacer()
                        NumberToggle(range: 30, res: $exercise.reps)
                            .background(Color("Background"))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .frame(width: 230)
                            .padding(.trailing, 10)
                    }
                    .frame(width: 320)
                    HStack{
                        Text("Weight")
                            .fontWeight(.medium)
                            .foregroundColor(Color("TitleColor"))
                            .padding(.leading, 10)
                        Spacer()
                        NumberToggle(range: 150, res: $exercise.weight)
                            .background(Color("Background"))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .frame(width: 230)
                            .padding(.trailing, 10)
                    }
                    .frame(width: 320)
                    .padding(.bottom, 10)
                        
                }
            }
        }
        .frame(width: 320)
        .background(Color("TabBar"))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

struct NumberToggle: View {
    var range: Int
    @Binding var res: Int
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(0...range, id: \.self) { number in
                    Button(action: {
                        res = number
                    }) {
                        Text("\(number)")
                            .font(.system(size: 20, weight: .bold))
                            .frame(width: 30, height: 30)
                            .background(res == number ? Color.purple : Color.gray.opacity(0.2))
                            .foregroundColor(res == number ? .white : .purple)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .animation(.easeInOut, value: res)
                    }
                }
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 6)
        }
    }
}

#Preview {
    MuscleGroupWidget(info: "figure.american.football", array: .constant([]), exercises: .constant([Exercise(name: "my exercise", muscle_group: "figure.american.football", is_selected: true, weight: 0, sets: 0, reps: 0)]))
}
