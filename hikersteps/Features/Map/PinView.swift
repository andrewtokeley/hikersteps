import SwiftUI
import Foundation
import Darwin

enum PinViewState {
    case selected
    case normal
    case dropped
}

struct PinView: View {
    var label: String
    var state: PinViewState = .normal
    
//    var fillColour: Color = .red
//    var isSelected: Bool = false
    
    @State private var scale: CGFloat = 0.0
        
    var body: some View {
        let size = 20.0
        VStack {
            ZStack {

                PinShape()
                    .fill(state == .normal ? .blue : (state == .selected ? .orange : .red))
                PinShape()
                    .stroke(Color.white.opacity(0.4), lineWidth: 1)
            }
            .shadow(radius: 10)
            .scaleEffect(scale, anchor: .bottom)
            .onAppear {
                withAnimation(Animation.interpolatingSpring(stiffness: 200, damping: 10).delay(0)) {
                    scale = 1.0
                }
            }
            .frame(width: size, height: size * 3 / 2)
            .padding(.bottom, 3)
            Text(label)
                .foregroundColor(Color.red)
                .font(.system(size: 13.5).bold())
                .shadow(color: .white, radius: 0, x: 0.5, y: 0.5)
                .shadow(color: .white, radius: 0, x: -0.5, y: 0.5)
                .shadow(color: .white, radius: 0, x: 0.5, y: -0.5)
                .shadow(color: .white, radius: 0, x: -0.5, y: -0.5)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 130)
        }
    }
    
    private struct PinShape: Shape {
        var hole: Bool = true
        
        func path(in rect: CGRect) -> Path {
            var path = Path()
            let circleRadius = rect.width / 2
            let circleCenter = CGPoint(x: rect.midX, y: circleRadius)
            let bottomPoint = CGPoint(x: rect.midX, y: rect.height)
            
            let angle: Double = Double.pi / 4
            
            let startPoint = CGPoint(x: circleRadius +  circleRadius * cos(Double(angle)), y: circleRadius + circleRadius * sin(angle))
            path.move(to: startPoint)
            path.addArc(center: circleCenter, radius: circleRadius, startAngle: .radians(.pi / 4), endAngle: .radians(.pi * 5 / -4), clockwise: true)
            path.addLine(to: bottomPoint)
            path.addLine(to: startPoint)
            
            // inner circle
            let holeRadius = circleRadius / 3 // Adjust the hole size as needed
            let holeCenter = CGPoint(x: rect.midX, y: circleRadius)
            path.addEllipse(in: CGRect(x: holeCenter.x - holeRadius, y: holeCenter.y - holeRadius, width: holeRadius * 2, height: holeRadius * 2))
            
            return path
        }
    }
}
