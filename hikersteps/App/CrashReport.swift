//
//  CrashReport.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 27/08/2025.
//

import SwiftUI

struct CrashReport: View {
    var details: String
    
    init(_ details: String) {
        self.details = details
    }
    
    var body: some View {
        ZStack {
            Color(.appPrimary)
                .ignoresSafeArea()
            
            Text(details)
        }
    }
}

#Preview {
    CrashReport("Something went wrong!")
}
