//
//  Hike.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 01/07/2025.
//

import SwiftUI

struct HikeView: View {
    // Defined and created in hikerstepsApp
    @EnvironmentObject var auth: AuthenticationManager
    
    // State owned by this view only
    @State private var showCheckInDetails = false
    @State private var selectedCheckIn: CheckIn?
    
    // StateOBject ensures this view us updated when Published properties change within the ViewModel
    @StateObject var viewModel = ViewModel()
    
    
    // Passed in from HomeView
    var hike: Hike

    init(hike: Hike) {
        self.hike = hike
    }
    
    /**
     Used by the Preview to inject a mock ViewModel and Hike instances
     */
    init(viewModel: ViewModel, hike: Hike) {
        self.hike = hike
        _viewModel = StateObject(wrappedValue: viewModel)
        _viewModel.wrappedValue.loadCheckIns(uid: "123", hike: hike)
    
    }
    
    /**
     Main View body
     */
    var body: some View {
        NavigationStack {
                MapView(checkIns: $viewModel.checkIns)
                    .edgesIgnoringSafeArea(.all)
            .onAppear {
                if let uid = auth.loggedInUser?.uid {
                    viewModel.loadCheckIns(uid: uid, hike: hike)
                }
            }
        }
    }
}

#Preview {
    let mock = AuthenticationManagerMock() as AuthenticationManager
    HikeView(
        viewModel: HikeView.ViewModelMock(),
        hike: Hike(description: "Walking the length of Aotearoa", name: "Te Araroa 2021/22", uid: "1"))
        .environmentObject(mock)
}
