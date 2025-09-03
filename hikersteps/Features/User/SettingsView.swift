//
//  Settings.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 23/07/2025.
//

import SwiftUI
import FirebaseAuth
import NukeUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var auth: AuthenticationManager
    
    @State private var showDistanceSelector: Bool = false
    @State private var viewModel: ViewModel
    
    /**
     Initialiser used only for testing to inject a test ViewModel
     */
    init(viewModel: ViewModel) {
        _viewModel = State(initialValue: viewModel)
    }
    
    /**
     Main initializer that creates an instance of ViewModel
     */
    init() {
        self.init(viewModel: ViewModel(userService: UserService(), userSettingsService: UserSettingsService()))
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                
                HStack {
                    VStack(alignment: .leading) {
                        Text(auth.user.displayName)
                            .bold()
                        Text(auth.user.email.isEmpty ? "(no email))" : auth.user.email)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    if let profileUrl = auth.user.profileUrl {
                        LazyImage(source: profileUrl) { state in
                            if let image = state.image {
                                image
                                    .resizingMode(.aspectFill)
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.circle")
                                    .font(.system(size: 50, weight: .thin))
                            }
                        }
                    } else {
                        Image(systemName: "person.circle")
                            .font(.system(size: 50, weight: .thin))
                    }
                }
                
                Divider()
                    .padding(.bottom)
                
                NavigationLink {
                    UsernameView(username: $auth.user.username)
                } label: {
                    HStack {
                        Image(systemName: "person.fill")
                            .frame(width: 30)
                        Text("Username")
                        Spacer()
                        Text(auth.user.username)
                            .foregroundStyle(.secondary)
                        Image(systemName: "chevron.right")
                    }
                    .padding(.vertical)
                }
                .buttonStyle(.plain)
                
                HStack {
                    Button {
                        showDistanceSelector = true
                    } label: {
                        HStack {
                            Image(systemName: "figure.walk")
                                .frame(width: 30)
                            Text("Preferred distance unit")
                            Spacer()
                            Text(auth.userSettings.preferredDistanceUnit.properName).foregroundStyle(.secondary)
                            Image(systemName: "chevron.down")
                        }
                        .padding(.vertical)
                    }
                    .buttonStyle(.plain)
                }
                
                HStack {
                    NavigationLink {
                        EmptyView()
                    } label: {
                        HStack {
                            Image(systemName: "icloud.and.arrow.down")
                                .frame(width: 30)
                            Text("Downloads")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .padding(.vertical)
                    }
                    .buttonStyle(.plain)
                }
                
                Divider()
                
                HStack {
                    Button {
                        // logout - this will change the app's phase to unautenticated and redirect to Home
                        Task {
                            try? await auth.logout()
                        }
                        
                    } label: {
                        HStack {
                            Image(systemName: "arrow.left.square")
                                .frame(width: 30)
                            Text("Log out")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .padding(.vertical)
                    }
                    .buttonStyle(.plain)
                }
                
                if auth.userSettings.email == "andrewtokeley@gmail.com" {
                    Button("Add Trails") {
                        Task {
                            do {
                                let service = TrailService()
                                try await service.addDefaults()
                            } catch {
                                ErrorLogger.shared.log(error)
                            }
                        }
                    }
                }
                Spacer()
                
                HStack {
                    Spacer()
                    VStack {
                        Text("version 1.3")
                        Text(viewModel.statusMessage ?? "")
                    }
                    Spacer()
                    
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .padding()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                }
            }
        }
        .sheet(isPresented: $showDistanceSelector) {
            AppListSelector<UnitLength>(
                items: [UnitLength.kilometers, UnitLength.miles],
                selectedItem: $auth.userSettings.preferredDistanceUnit,
                title: "Prefered Distance Unit",
                noSelection: false
            )
            {
                return SelectableItem(id: UUID().uuidString, name: $0.properName)
            }
//            AppListSelector<Unit>(
//                items: [Unit.km, Unit.mi],
//                selectedItem: $auth.userSettings.preferredDistanceUnit,
//                title: "Preferred Unit") {
//                    SelectableItem(id: UUID().uuidString, name: $0.properName)
//                }
//                .presentationDetents([.height(200)])
        }
        .onDisappear {
            Task {
                do {
                    try await auth.persistUserAndSettings()
                } catch {
                    ErrorLogger.shared.log(error)
                }
            }
        }
    }
}

#Preview {
    SettingsView(viewModel: SettingsView.ViewModel(userService: UserService.Mock(), userSettingsService: UserSettingsService.Mock()))
        .environmentObject(AuthenticationManager.forPreview())
}
