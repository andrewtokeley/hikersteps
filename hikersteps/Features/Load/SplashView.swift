//
//  SplashView.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 01/07/2025.
//

import SwiftUI

struct SplashView: View {
  var body: some View {
    ZStack {
      Color(.systemBackground)
        .ignoresSafeArea()

      VStack {
        Image(systemName: "leaf.circle.fill")
          .resizable()
          .scaledToFit()
          .frame(width: 100, height: 100)
          .foregroundColor(.green)
      }
    }
  }
}

#Preview {
  SplashView()
}
