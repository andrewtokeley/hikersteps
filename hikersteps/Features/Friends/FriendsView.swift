//
//  FriendsView.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 17/09/2025.
//

import SwiftUI

struct FriendsView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Share journals amongst your friends")
                    .font(.caption)
                
                AppCapsuleButton("Invite a friend...")
                    .padding(.vertical)
                
                Divider()
                    .padding(.vertical)
                
                Text("Your friends")
                    .font(.title)
                    .bold()
                HStack {
                    ProfileImage(username: "peter-piper")
                    Text("peter-piper")
                    Spacer()
                    AppCircleButton(imageSystemName: "ellipsis", rotationAngle: Angle(degrees: 90))
                }
                HStack {
                    ProfileImage(username: "nicole")
                    Text("nicole")
                    Spacer()
                    AppCircleButton(imageSystemName: "ellipsis", rotationAngle: Angle(degrees: 90))
                }
            }
            .padding()
            .navigationTitle("Manage Friends")
            .navigationBarTitleDisplayMode(.inline)
            
        }
    }
}

#Preview {
    FriendsView()
}
