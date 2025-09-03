//
//  UsernameView.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 27/08/2025.
//

import SwiftUI

struct UsernameView: View {
    @Environment(\.dismiss) var dismiss
    
    @Binding var username: String
    
    @State private var debounceTask: Task<Void, Never>?
    @StateObject private var viewModel: ViewModel
    
    @FocusState private var focusedView: FocusableViews?
    
    enum FocusableViews: Hashable {
        case username
    }
    
    init(username: Binding<String>) {
        _username = username
        _viewModel = StateObject(wrappedValue: ViewModel(userService: UserService(), initialUsername: username.wrappedValue))
        self.focusedView = .username
    }
    
    var body: some View {
        NavigationStack {
            VStack (alignment: .leading) {
                
                TextField("Enter username", text: $viewModel.username)
                    .padding()
                    .styleBorderLight(focused: focusedView == .username)
                    .focused($focusedView, equals: .username)
                    .padding(.bottom)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .onChange(of: viewModel.username) { oldValue, newValue in
                        let filtered = newValue.filter { $0.isLetter }
                        if filtered != newValue {
                            viewModel.username = filtered
                            viewModel.keyPressed()
                        }
                    }
                
                Group {
                    Text("Your username will be shown in journal comments and links to your own journals.")
                        .padding(.leading, 5)
                }
                    .font(.caption)
                    .padding(.bottom, 20)
                
                VStack {
                    AppCapsuleButton("Update", width: 100) {
                        self.username = viewModel.username
                        dismiss()
                    }
                    .capsuleStyle(.filled)
                    .disabled(!viewModel.isAvailable)
                    
                    if let message = viewModel.availabilityMessage {
                        Text(message)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    @Previewable @State var username: String = ""
    VStack {
        Text(username)
        UsernameView(username: $username)
    }
}
