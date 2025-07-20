//
//  TextPinAnnotationView.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 02/07/2025.
//

import Foundation
import MapKit

class CheckInAnnotationView: MKAnnotationView {
    private let pinBackground = UIImageView()
    private let label = UILabel()
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        frame = CGRect(x: 0, y: 0, width: 30, height: 40)
        centerOffset = CGPoint(x: 0, y: -20) // Align pin point
        
        // Use system-like pin shape
        let pinImage = drawPinShape(color: .systemRed, rect: frame)
        pinBackground.image = imageFromPath(path: pinImage, size: frame.size)
        pinBackground.frame = bounds
        addSubview(pinBackground)
        
        // Text overlay
        label.frame = CGRect(x: 0, y: 5, width: bounds.width, height: 25)
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.numberOfLines = 1
        
        label.text = self.annotation?.title ?? ""
        
        addSubview(label)
        
        canShowCallout = false
    }
    
    private func drawPinShape(color: UIColor, rect: CGRect) -> UIBezierPath {
        // Teardrop-style pin
        let width = rect.width
        let height = rect.height
        let radius = width / 2
        
        let center = CGPoint(x: width / 2, y: radius)
        let path = UIBezierPath()
        
        // Start at bottom point (tip of pin)
        path.move(to: CGPoint(x: width / 2, y: height))
        
        // Left curve up to top
        path.addQuadCurve(
            to: CGPoint(x: 0, y: radius),
            controlPoint: CGPoint(x: 0, y: height * 0.75)
        )
        
        // Arc across the top (half circle)
        path.addArc(
            withCenter: center,
            radius: radius,
            startAngle: .pi,
            endAngle: 0,
            clockwise: true
        )
        
        // Right curve down to bottom
        path.addQuadCurve(
            to: CGPoint(x: width / 2, y: height),
            controlPoint: CGPoint(x: width, y: height * 0.75)
        )
        
        path.close()
        
        return path
    }
    
    private func imageFromPath(path: UIBezierPath, size: CGSize, fillColor: UIColor = .systemRed, shadow: Bool = true) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            let cgContext = context.cgContext
            
            if shadow {
                cgContext.setShadow(offset: CGSize(width: 0, height: 2),
                                    blur: 4,
                                    color: UIColor.black.withAlphaComponent(0.3).cgColor)
            }
            
            fillColor.setFill()
            path.fill()
        }
    }
}
