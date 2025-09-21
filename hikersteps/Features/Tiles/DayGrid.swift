//
//  DayGrid.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 18/09/2025.
//

import SwiftUI

struct DayGrid: View {
    
    @Binding var checkIns: [CheckIn]
    @Binding var selectedIndex: Int
    
    var onSelected: ((CheckIn) -> Void)?
    
    private var checkInManager: CheckInManager {
        return CheckInManager(checkIns: checkIns)
    }
    
    init(checkIns: Binding<[CheckIn]>, selectedIndex: Binding<Int>) {
        _checkIns = checkIns
        _selectedIndex = selectedIndex
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 90), spacing: 3)],
                      spacing: 3) {
                ForEach(Array(checkIns.enumerated()), id: \.element.id) { index, checkIn in
                    TileView(imageUrlString: checkIn.image.storageUrl, title: checkInManager.dayDescription(checkIn))
                        .overlay(
                            RoundedRectangle(cornerRadius: 0)
                                .stroke(Color(selectedIndex == index ? .appOrange : .clear), lineWidth: 2)
                        )
                        .onTapGesture {
                            onSelected?(checkIn)
                            selectedIndex = index
                        }
                }
            }
        }
//        .background(Color(.appLightGray))
    }
    
    func onSelected(_ handler:((CheckIn) -> Void)?) -> DayGrid {
        var copy = self
        copy.onSelected = handler
        return copy
    }
}

#Preview {
    @Previewable @State var checkIns = [
        CheckIn.sample(),
        CheckIn.sample(image: StorageImage.sampleLongImage),
        CheckIn.sample(date: Calendar.current.date(byAdding: .day, value: 1, to: Date())!, image: StorageImage.sampleLongImage),
        CheckIn.sample(date: Calendar.current.date(byAdding: .day, value: 2, to: Date())!, image: StorageImage.sample)
    ]
    @Previewable @State var selectedIndex: Int = 0
    DayGrid(checkIns: $checkIns, selectedIndex: $selectedIndex)
}
