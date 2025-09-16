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
    private var username: String
    private var userService: any UserServiceProtocol
    
    @State private var profileUrl: URL? = nil
    
    init(_ size: ProfileImageSize = .medium, username: String) {
        self.init(size, username: username, userService: UserService())
    }
    
    init(_ size: ProfileImageSize = .medium, username: String, userService: any UserServiceProtocol) {
        self.size = size.size
        self.username = username
        self.userService = userService
    }
    
    var body: some View {
        VStack {
            if let _ = profileUrl {
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
        .task {
            do {
                let user = try await userService.getUser(username: username)
                self.profileUrl = user?.profileUrl
            } catch {
                ErrorLogger.shared.log(error)
            }
        }
    }
}

#Preview {
    VStack {
        ProfileImage(username: "tokes", userService: UserService.Mock())
        ProfileImage(.small, username: "nicole", userService: UserService.Mock())
        ProfileImage(.medium, username: "james", userService: UserService.Mock())
        ProfileImage(.large, username: "tonic", userService: UserService.Mock())
    }
    .environmentObject(AuthenticationManager.forPreview())
}
