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
    @State private var offset: CGFloat = -400
    @State var isActive: Bool = false
    @Binding var bar: Bool
    var body: some View {
        ZStack {
            VStack(){
                HStack{
                    Text("Экран 3")
                        .font(.system(size: 35))
                        .fontWeight(.semibold)
                        .foregroundColor(Color("TitleColor"))
                    Spacer()
                    Button {
                        isActive = true
                        bar = false
                    } label: {
                        ZStack{
                            RoundedRectangle(cornerRadius: 20)
                                .fill(LinearGradient(gradient: Gradient(colors: [Color("PurpleColor"), Color.purple]),
                                        startPoint: .leading,
                                        endPoint: .trailing))
                                .frame(width: 50, height: 50)
                            Image(systemName:"plus.circle")
                                .resizable()
                                .frame(width: 35, height: 35)
                                .foregroundColor(Color.white)
                        }
                    }
                }
                .padding(.horizontal, 20)
                Spacer().frame(height: 30)
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 30) {
                        //Spacer().frame(height: 1)
                        ForEach(workouts) { workout in
                            WorkoutWidget(workout: workout)
                        }
                        Spacer().frame(height: 60)
                    }
                }
            }
            if isActive {
                WorkoutBuilder(isActive: $isActive, bar: $bar)
            }
        }
        .offset(x: offset)
        .onAppear {
            withAnimation(.spring()) {
                offset = 0
            }
        }
    }
}

#Preview {
    TrainingsList(bar: .constant(true))
}
