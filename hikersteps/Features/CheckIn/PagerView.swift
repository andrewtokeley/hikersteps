//
//  PagerView.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 30/07/2025.
//

import SwiftUI
import CoreLocation

//struct PagerView<Item: Identifiable & Equatable, Content: View>: View {
//    @Binding var checkIns: [CheckIn]
//    @Binding var selectedIndex: Int
//    @Binding var dayDescription: String?
//    
//    let content: (Item) -> Content
//    
//    var body: some View {
//        TabView(selection: $selectedIndex) {
//            ForEach(Array(checkIns.enumerated()), id: \.element.id) { index, checkIn in
//                checkInView($checkIn, "Day \(index)")
//                    .tag(index)
//            }
//        }
//        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
//    }
//}
//
//#Preview {
////    @Previewable @State var selectedIndex = 1
////    @Previewable @State var checkIns = [
////        CheckIn(id: "1", uid: "xxx", location: CLLocationCoordinate2D(latitude: -41.19, longitude: 174.7787), title: "Brakenexk Speed Camp", date: Calendar.current.date(byAdding: .day, value: 1, to: Date())!),
////        CheckIn(id: "2",  uid: "xxx", location: CLLocationCoordinate2D(latitude: -41.29, longitude: 174.7787), title: "Wild Camping", date: Calendar.current.date(byAdding: .day, value: 2, to: Date())!),
////        CheckIn(id: "3", uid: "xxx", location: CLLocationCoordinate2D(latitude: -41.39, longitude: 174.7787), title: "Cherokee Point Camp", date: Calendar.current.date(byAdding: .day, value: 3, to: Date())!),
////    ]
////    PagerView(checkIns: $checkIns, selectedIndex: $selectedIndex) { checkIn, dayDescription in
////        CheckInView(checkIn: checkIn, dayDescription: dayDescription)
////    }
//}
