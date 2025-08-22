//
//  HikeDetails.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 08/08/2025.
//

import SwiftUI

struct JournalDetailsView: View {
    
    @State private var showShare = false
    @State private var topSectionHeight: CGFloat = 200
    
    let journal: Journal
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                if let url = URL(string: journal.heroImageUrl) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(height: topSectionHeight + topSafeAreaInset())
                            .frame(maxWidth: .infinity)
                            .clipped()
                            .ignoresSafeArea(edges: .top)
                            .frame(height: topSectionHeight)
                    } placeholder: {
                        Color(.appLightGray)
                            .ignoresSafeArea(edges: .top)
                            .frame(height: topSectionHeight)
                    }
                } else {
                    Image("hiker-journal")
                        .resizable()
                        .scaledToFill()
                        .frame(height: topSectionHeight + topSafeAreaInset())
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .ignoresSafeArea(edges: .top)
                        .frame(height: topSectionHeight)
                }
                VStack {
                    List {
                        HStack {
                            NavigationLink {
                                JournalView(journal: journal)
                                //HikeView(hike: hike, showCheckIn: hike.statistics.latestCheckIn)
                            } label: {
                                Text("Latest Entry")
                                Spacer()
                                Text(journal.statistics.latestCheckInDate.formatted(.dateTime.weekday().day().month().year()))
                                Image("chevron.right")
                            }
                        }
                    }
//                    VStack (spacing: 10) {
//                        HStack {
//                            Group {
//                                StatisticView(numberUnit: hike.statistics.totalDistanceWalked, description: "Total Distance")
//                                StatisticView(numberUnit: hike.statistics.longestDistance, description: "Longest Day")
//                            }
//                            .frame(width: 170)
//                        }
//                        
//                        HStack (alignment: .top) {
//                            Group {
//                                StatisticView(numberUnit: hike.statistics.totalDays, description: "Days")
//                                
//                                StatisticView(numberUnit: hike.statistics.totalRestDays, description: "Rest Days")
//                            }
//                            .frame(width: 170)
//                        }
//                    }
//                    .padding()
//                    Spacer()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                AppBackButton()
            }
            ToolbarItem(placement: .topBarTrailing) {
                AppCircleButton(size: 30, imageSystemName: "square.and.arrow.up", bottomNudge: 5) {
                    showShare = true
                }
                .style(.filledOnImage)
            }
        }
        .sheet(isPresented: $showShare) {
            Text("Share...")
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }
    
    func topSafeAreaInset() -> CGFloat {
        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let window = scene?.windows.first
        return window?.safeAreaInsets.top ?? 0
    }
    func statusBarHeight() -> CGFloat {
        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let window = scene?.windows.first
        return window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
    }
}

#Preview {
    JournalDetailsView(journal: Journal.sample)
}
