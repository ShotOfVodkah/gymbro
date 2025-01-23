//
//  Shapes.swift
//  GymBro
//
//  Created by Stepan Polyakov on 23.01.2025.
//

import SwiftUICore

struct Trapezoid: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0, y: 0.18134*height))
        path.addCurve(to: CGPoint(x: 0.05871*width, y: 0.00208*height), control1: CGPoint(x: 0, y: 0.07465*height), control2: CGPoint(x: 0.02729*width, y: -0.00868*height))
        path.addLine(to: CGPoint(x: 0.95204*width, y: 0.30791*height))
        path.addCurve(to: CGPoint(x: width, y: 0.48717*height), control1: CGPoint(x: 0.97928*width, y: 0.31723*height), control2: CGPoint(x: width, y: 0.39469*height))
        path.addLine(to: CGPoint(x: width, y: 0.81982*height))
        path.addCurve(to: CGPoint(x: 0.94667*width, y: height), control1: CGPoint(x: width, y: 0.91933*height), control2: CGPoint(x: 0.97612*width, y: height))
        path.addLine(to: CGPoint(x: 0.05333*width, y: height))
        path.addCurve(to: CGPoint(x: 0, y: 0.81982*height), control1: CGPoint(x: 0.02388*width, y: height), control2: CGPoint(x: 0, y: 0.91933*height))
        path.addLine(to: CGPoint(x: 0, y: 0.18134*height))
        path.closeSubpath()
        return path
    }
}

struct TabBar: Shape {
    func path(in rect: CGRect) -> Path {
            var path = Path()
            let width = rect.size.width
            let height = rect.size.height
            path.addRect(CGRect(x: 0.4372*width, y: 0.2314*height, width: 0.14976*width, height: 0.53719*height))
            path.move(to: CGPoint(x: 0, y: 0))
            path.addCurve(to: CGPoint(x: 0.50725*width, y: 0.44215*height), control1: CGPoint(x: 0.19809*width, y: 0.17267*height), control2: CGPoint(x: 0.28261*width, y: 0.45041*height))
            path.addCurve(to: CGPoint(x: width, y: 0), control1: CGPoint(x: 0.73188*width, y: 0.43388*height), control2: CGPoint(x: 0.80757*width, y: 0.17267*height))
            path.addLine(to: CGPoint(x: width, y: height))
            path.addLine(to: CGPoint(x: 0, y: height))
            path.addLine(to: CGPoint(x: 0, y: 0))
            path.closeSubpath()
            return path
    }
}
