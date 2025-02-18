//
//  WorkoutBuilder.swift
//  GymBro
//
//  Created by Stepan Polyakov on 25.01.2025.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreCombineSwift
import Firebase

struct WorkoutBuilder: View {
    @Binding var isActive: Bool
    @Binding var bar: Bool
    
    @FirestoreQuery(collectionPath: "exercises") var exercises: [Exercise]
    
    @State private var ex: [Exercise] = []
    @State private var chosen_exercises: [Exercise] = []
    @State private var offset: CGFloat = 1000
    @State private var opacity: Double = 0
    
    @State private var isFinished: Bool = false
    
    var body: some View {
        ZStack {
            Blur().edgesIgnoringSafeArea(.all)
                .opacity(opacity)
            ZStack(alignment: .top) {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color("TabBar"))
                    .frame(width: 375, height: 650)
                Exercise_choice(chosen_exercises: $chosen_exercises, exercises: $ex, isFinished: $isFinished, closeAction: close)
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
                        print("\(newChosenExercises.map { $0.name })")
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
        chosen_exercises = []
        isFinished = false
    }
}

#Preview {
    WorkoutBuilder(isActive: .constant(true), bar: .constant(false))
}

struct Exercise_choice: View {
    var mGroups: [String] = ["Chest", "Back", "Buttocks", "Lower legs", "Arms", "Upper legs", "Shoulders"]
    @Binding var chosen_exercises: [Exercise]
    @Binding var exercises: [Exercise]
    @State private var offset: CGFloat = 0
    @Binding var isFinished: Bool
    
    var closeAction: () -> Void
    
    var body: some View {
        ZStack {
            if isFinished {
                Exercise_finish(chosen_exercises: $chosen_exercises, closeAction: closeAction)
            } else {
                ScrollView(showsIndicators: false) {
                    Spacer(minLength: 135)
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
                        .disabled(chosen_exercises.isEmpty)
                        .opacity(chosen_exercises.isEmpty ? 0 : 1)
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
    @State private var buttonTapped: Bool = false
    
    @State private var name: String = ""
    @State private var chosen_icon: String = "figure.walk.treadmill"
    var icons: [String] = ["figure.walk.treadmill", "figure.american.football", "figure.barre", "figure.cooldown", "figure.highintensity.intervaltraining"]
    
    @State private var offset: CGFloat = 800
    
    var closeAction: () -> Void
    
    var body: some View {
        ZStack {
            VStack(spacing: 10) {
                Spacer(minLength: 120)
                HStack {
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            buttonTapped.toggle()
                        }
                    } label: {
                        Image(systemName: chosen_icon)
                            .font(.system(size: 45))
                            .foregroundColor(Color("TitleColor"))
                            .frame(width: 70, height: 70)
                            .background(RoundedRectangle(cornerRadius: 15)
                                        .fill(Color("Background")))
                    }
                    VStack{
                        Text("Name your workout")
                            .font(.system(size: 25))
                            .foregroundColor(Color("TitleColor"))
                        TextField("", text: $name)
                            .padding(.horizontal,1)
                            .padding(.vertical, 5)
                            .background(RoundedRectangle(cornerRadius: 20)
                                        .fill(Color("Background"))
                                )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color("PurpleColor"), lineWidth: 2)
                            )
                    }
                }
                
                if buttonTapped {
                    IconToggle(chosen_icon: $chosen_icon, icons: icons)
                }
                
                Text("Put your exercises in order")
                    .font(.system(size: 25))
                    .foregroundColor(Color("TitleColor"))
                ScrollView(showsIndicators: false) {
                    ForEach(chosen_exercises, id: \.self) {exercise in
                        ZStack {
                            BackgroundAnimation().scaleEffect(0.5)
                                .offset(x: -100)
                            HStack {
                                Image(exercise.muscle_group)
                                    .scaleEffect(0.1)
                                    .frame(width: 30, height: 30)
                                    .padding(.trailing, 10)
                                Text(exercise.name)
                                    .font(.system(size: 25))
                                Spacer()
                                Image(systemName: "text.justify")
                                    .scaleEffect(1.5)
                            }
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
                        .onAppear {
                                                    print("Exercise: \(exercise.name), Sets: \(exercise.sets), Reps: \(exercise.reps), Weight: \(exercise.weight)")
                                                }
                    }
                }
            }
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        createWorkout(name: name, exercises: chosen_exercises, icon: chosen_icon)
                        closeAction()
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
                    .disabled(name.isEmpty)
                    .opacity(name.isEmpty ? 0 : 1)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(10)
        .offset(x: offset)
        .onAppear {
            withAnimation(.spring()) {
                offset = 400
            }
        }
    }
}

struct IconToggle: View {
    @Binding var chosen_icon: String
    var icons: [String]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(icons, id: \.self) { icon in
                    Button(action: {
                        chosen_icon = icon
                    }) {
                        Image(systemName: icon)
                            .font(.system(size: 24, weight: .bold))
                            .frame(width: 60, height: 60)
                            .scaleEffect(1.5)
                            .background(chosen_icon == icon ? Color("PurpleColor") : Color("Background"))
                            .foregroundColor(chosen_icon == icon ? .white : Color("PurpleColor"))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .animation(.easeInOut, value: chosen_icon)
                    }
                }
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 6)
            .background(Color.gray.opacity(0.4))
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }
}
