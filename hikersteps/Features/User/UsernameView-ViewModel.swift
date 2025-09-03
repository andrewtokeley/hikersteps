//
//  UsernameView-ViewModel.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 30/08/2025.
//

import Foundation
import Combine

extension UsernameView {
    
    @MainActor
    protocol ViewModelProtocol: ObservableObject {
        
        init(userService: UserServiceProtocol, initialUsername: String)
        
        var isAvailable: Bool { get }
        
        func checkAvailability(_ username: String) async throws
        
        func keyPressed()
    }
    
    class ViewModel: ViewModelProtocol {
        @Published var username: String = ""
        @Published var isAvailable: Bool = false
        @Published var isChecking: Bool = false
        @Published var availabilityMessage: String? = nil
        
        private var userService: UserServiceProtocol
        private var bag = Set<AnyCancellable>()
        
        required init(userService: UserServiceProtocol, initialUsername: String = "") {
            self.username = initialUsername
            self.userService = userService
            
            $username
                .removeDuplicates()
                .debounce(for: .seconds(1), scheduler: RunLoop.main)
                .sink { [weak self] value in
                    Task {
                        try? await self?.checkAvailability(value)
                    }
                }
                .store(in: &bag)
        }
        
        private func normalized(_ s: String) -> String { s.trimmingCharacters(in: .whitespacesAndNewlines) }
        
        func keyPressed() {
            // assume the worse until the check is initiated
            self.isAvailable = false
        }
        
        func checkAvailability(_ username: String) async throws {
            self.isChecking = true
            let name = normalized(username)
            guard !name.isEmpty else { isAvailable = false; return }
            
            do {
                // for availability you typically want EXACT match, not prefix:
                let taken = try await userService.getUser(username: name)
                isAvailable = taken == nil
                availabilityMessage = !isAvailable ? "'\(username)' already taken" : nil
            } catch {
                isAvailable = false
            }
            self.isChecking = false
        }
    }
}
