//
//  ShareSheet.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 27/08/2025.
//

import SwiftUI


struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
 
    init(activityItems: [Any]) {
        self.activityItems = activityItems
    }
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities:nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        
    }
}

