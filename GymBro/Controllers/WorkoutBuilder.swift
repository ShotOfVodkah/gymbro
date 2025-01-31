//
//  WorkoutBuilder.swift
//  GymBro
//
//  Created by Stepan Polyakov on 25.01.2025.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreCombineSwift

struct WorkoutBuilder: View {
    @Binding var isActive: Bool
    @Binding var bar: Bool
    
    @FirestoreQuery(collectionPath: "exercises") var exercises: [Exercise]
    
    @State private var ex: [Exercise] = []
    @State private var chosen_exercises: [Exercise] = []
    @State private var offset: CGFloat = 1000
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            Blur().edgesIgnoringSafeArea(.all)
                .opacity(opacity)
            ZStack(alignment: .top) {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color("TabBar"))
                    .frame(width: 375, height: 650)
                Exercise_choice(chosen_exercises: $chosen_exercises, exercises: $ex)
                Trapezoid()
                    .fill(LinearGradient(gradient: Gradient(colors: [Color("PurpleColor"), Color.purple]),startPoint: .leading,endPoint: .trailing))
                    .frame(width: 375, height: 150)
                    .scaleEffect(x: 1, y: -1)
                VStack(spacing: 10){
                    HStack() {
                        Spacer()
                        Text("Новая тренировка")
                            .font(.system(size: 30))
                            .fontWeight(.bold)
                            .padding(.top, 15)
                            .padding(.leading, 35)
                            .foregroundColor(.white)
                        Spacer()
                        Button {
                            close()
                        } label: {
                            Image(systemName: "xmark").resizable()
                                .frame(width: 20, height: 20)
                        }
                        .tint(.white)
                        .padding([.top, .trailing], 15)
                    }
                    Text("Choose the exercises for your workout")
                        .font(.system(size: 25))
                        .padding(.leading, 15)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                }
            }
            .frame(width: 375, height: 600)
            .offset(y: offset)
            .onAppear {
                withAnimation(.spring()) {
                    offset = 0
                }
                withAnimation(.easeIn(duration: 0.5)) {
                    opacity = 1
                }
            }
            .onChange(of: exercises) { newExercises in
                self.ex = newExercises
            }
            .onChange(of: chosen_exercises) { newChosenExercises in
                        print("Chosen Exercises Updated: \(newChosenExercises.map { $0.name })")
                    }
        }
    }
    
    func close() {
        withAnimation(.spring()) {
            offset = 750
            isActive = false
            bar = true
        }
        withAnimation(.easeOut(duration: 0.5)) {
            opacity = 0
        }
    }
}

#Preview {
    WorkoutBuilder(isActive: .constant(true), bar: .constant(false))
}

struct Exercise_choice: View {
    var mGroups: [String] = ["figure.american.football", "figure.run.treadmill", "figure.roll", "figure.archery", "figure.barre"]
    @Binding var chosen_exercises: [Exercise]
    @Binding var exercises: [Exercise]
    @State private var offset: CGFloat = 0
    @State private var isFinished: Bool = false
    
    var body: some View {
        ZStack {
            if isFinished {
                Exercise_finish(chosen_exercises: $chosen_exercises)
            } else {
                ScrollView(showsIndicators: false) {
                    Spacer(minLength: 160)
                        ForEach(mGroups, id: \.self) { item in
                            VStack {
                                MuscleGroupWidget(info: item, array: $chosen_exercises, exercises: $exercises)
                            }
                            .background(Color("TabBar"))
                            .cornerRadius(12)
                            .padding(.bottom, 10)
                        }
                }
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            close()
                        } label: {
                            Image(systemName: "arrow.right")
                                .foregroundColor(.white)
                                .padding(5)
                                .background(Circle().fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [Color("PurpleColor"), Color.purple]),
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                    )
                                )
                                .scaleEffect(2.5)
                        }
                        .padding(13)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(16)
        .offset(x: offset)
    }
    
    private func close() {
        withAnimation(.spring()) {
            offset = -400
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isFinished = true
            }
        }
    }
}

struct Exercise_finish: View {
    @Binding var chosen_exercises: [Exercise]
    @State private var dragged: Exercise?
    
    @State private var name: String = ""
    
    @State private var offset: CGFloat = 800
    
    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                Spacer(minLength: 160)
                TextField("Введите текст", text: $name)
                                .padding()
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                Text("Put your exercises in order")
                    .font(.system(size: 25))
                    .foregroundColor(Color("TitleColor"))
                ForEach(chosen_exercises, id: \.self) {exercise in
                    HStack {
                        Image(systemName: exercise.muscle_group)
                            .scaleEffect(1.5)
                            .padding(.trailing, 10)
                        Text(exercise.name)
                            .font(.system(size: 25))
                        Spacer()
                        Image(systemName: "text.justify")
                            .scaleEffect(1.5)
                    }
                    .padding()
                    .background(Color("Background"))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .foregroundColor(Color("TitleColor"))
                    .onDrag({
                        self.dragged = exercise
                        return NSItemProvider()
                    })
                    .onDrop(of: [.text], delegate: DragDropDelegate(destinationItem: exercise, selected: $chosen_exercises, draggedItem: $dragged))
                }
            }
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        
                    } label: {
                        Image(systemName: "checkmark")
                            .foregroundColor(.white)
                            .padding(5)
                            .background(Circle().fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color("PurpleColor"), Color.purple]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                )
                            )
                            .scaleEffect(2.5)
                    }
                    .padding(13)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(16)
        .offset(x: offset)
        .onAppear {
            withAnimation(.spring()) {
                offset = 400
            }
        }
    }
    
    private func close() {
        withAnimation(.spring()) {
            
        }
    }
}
