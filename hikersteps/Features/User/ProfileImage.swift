//
//  ProfileImage.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 12/09/2025.
//

import SwiftUI
import NukeUI

enum ProfileImageSize {
    case small
    case medium
    case large
    
    internal var size: CGFloat {
        switch self {
        case .small: return 35
        case .medium: return 45
        case .large: return 60
        }
    }
}

struct ProfileImage: View {
    @EnvironmentObject var auth: AuthenticationManager
    
    private var size: CGFloat
    
    init(_ size: ProfileImageSize = .medium) {
        self.size = size.size
    }
    
    var body: some View {
        if let profileUrl = auth.user.profileUrl {
            LazyImage(source: profileUrl) { state in
                if let image = state.image {
                    image
                        .resizingMode(.aspectFill)
                        .frame(width: self.size, height: self.size)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.circle")
                        .font(.system(size: self.size, weight: .thin))
                }
            }
        } else {
            Image(systemName: "person.circle")
                .font(.system(size: self.size, weight: .thin))
        }
    }
}

#Preview {
    VStack {
        ProfileImage()
        ProfileImage(.small)
        ProfileImage(.medium)
        ProfileImage(.large)
    }
    .environmentObject(AuthenticationManager.forPreview())
}
