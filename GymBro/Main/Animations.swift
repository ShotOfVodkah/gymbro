//
//  Animations.swift
//  GymBro
//
//  Created by Stepan Polyakov on 23.01.2025.
//

import SwiftUI


struct BackgroundAnimation: View {
    @State private var positions: [CGPoint] = [
        CGPoint(x: 50, y: 800),
        CGPoint(x: 400, y: 500),
        CGPoint(x: 200, y: 200)
    ]
    @State private var directions: [CGSize] = [
        CGSize(width: 1, height: 1),
        CGSize(width: -1, height: 1),
        CGSize(width: 1, height: -1)
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<positions.count, id: \.self) { index in
                    Circle()
                        .fill(Color("BackgroundB"))
                        .frame(width: 300, height: 300)
                        .blur(radius: 100)
                        .position(positions[index])
                        .opacity(0.7)
                }
            }
            .onAppear {
                withAnimation(Animation.linear(duration: 6).repeatForever(autoreverses: true)) {
                    moveBalls(geometry.size)
                }
            }
        }
        .ignoresSafeArea()
    }

    private func moveBalls(_ size: CGSize) {
        for index in positions.indices {
            positions[index].x += directions[index].width * CGFloat.random(in: 50...150)
            positions[index].y += directions[index].height * CGFloat.random(in: 50...150)
            if positions[index].x - 200 / 2 <= 0 || positions[index].x + 200 / 2 >= size.width {
                directions[index].width *= -1
            }
            if positions[index].y - 200 / 2 <= 0 || positions[index].y + 200 / 2 >= size.height {
                directions[index].height *= -1
            }
        }
    }
}

struct GradientAnimation: View {
    @State var start = UnitPoint(x:0, y: -2)
    @State var end = UnitPoint(x:4, y: 0)
    
    let timer = Timer.publish(every: 1, on: .main, in: .default).autoconnect()
    let colors = [Color.orange, Color.pink,  Color("PurpleColor"), Color.purple]
    
    
    var body: some View {
        LinearGradient(gradient: Gradient(colors: colors), startPoint: start, endPoint: end)
            .animation(Animation.easeInOut(duration: 2).repeatForever()).onReceive(timer, perform: { _ in
                self.start = UnitPoint(x:4, y: 0)
                self.end = UnitPoint(x:0, y: 2)
                self.start = UnitPoint(x:-20, y: 80)
                self.start = UnitPoint(x:4, y: 0)
            })
            .ignoresSafeArea(.all)
        
    }
}

#Preview {
    GradientAnimation()
}
