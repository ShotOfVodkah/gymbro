//
//  WorkoutPlayer.swift
//  GymBro
//
//  Created by Stepan Polyakov on 16.02.2025.
//

import SwiftUI

struct WorkoutPlayer: View {
    var body: some View {
        ZStack {
            Color("Background").ignoresSafeArea()
            BackgroundAnimation()
        }
    }
}

#Preview {
    WorkoutPlayer()
}
