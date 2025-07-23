//
//  Settings.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 23/07/2025.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var auth: AuthenticationManager
    
    @State private var showDistanceSelector: Bool = false
    @State private var userSettings: UserSettings = UserSettings.sample()
    
    // Set when the user selects a preferred distance unit
    @State private var selectedDistanceUnitLookup: LookupItem?
    
    // Conversion of lookup item into Unit
    private func selectedDistanceUnit() -> Unit? {
        return Unit(rawValue: selectedDistanceUnitLookup?.id ?? "mi")
    }
    
    init() {
        _selectedDistanceUnitLookup = State(initialValue: LookupItem(id: userSettings.preferredDistanceUnit.rawValue, name: userSettings.preferredDistanceUnit.properName))
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                if (auth.isLoggedIn) {
                    if let user = auth.loggedInUser {
                        Text(user.displayName!)
                            .bold()
                        Text(user.email!)
                            .foregroundStyle(.secondary)
                    }
                }
                Divider()
                
                HStack {
                    Button {
                        showDistanceSelector = true
                    } label: {
                        HStack {
                            Image(systemName: "figure.walk")
                            Text("Preferred Distance Unit")
                            Spacer()
                            Text("\(selectedDistanceUnit()?.properName ?? "not selected" )").foregroundStyle(.secondary)
                            Image(systemName: "chevron.down")
                        }
                        .padding()
                        .styleBorderLight()
                    }
                    .buttonStyle(.plain)
                }
                
                Spacer()
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
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
            AppListSelector(selectedItem: $selectedDistanceUnitLookup, items: [
                LookupItem(id: Unit.mi.rawValue, name: Unit.mi.properName),
                LookupItem(id: Unit.km.rawValue, name: Unit.km.properName)
            ], title: "Distance Unit")
                .presentationDetents([.height(200)])
        }
        
    }
}

#Preview {
    let mock = AuthenticationManagerMock() as AuthenticationManager
    SettingsView().environmentObject(mock)
}
