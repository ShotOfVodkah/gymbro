//
//  TrainingsList.swift
//  GymBro
//
//  Created by Александра Грицаенко on 21.01.25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreCombineSwift

struct TrainingsList: View {
    @FirestoreQuery(collectionPath: "workouts") var workouts: [Workout]
    var body: some View {
        VStack(){
            Text("Экран 3")
                .font(.largeTitle)
                .foregroundColor(Color("PurpleColor"))
            //List(workouts) {a in Text(a.name)}
            ScrollView(showsIndicators: false) {
                VStack(spacing: 30) {
                    ForEach(workouts) { workout in
                        WorkoutWidget(workout: workout)
                    }
                }
            }
        }
    }
}

#Preview {
    TrainingsList()
}
