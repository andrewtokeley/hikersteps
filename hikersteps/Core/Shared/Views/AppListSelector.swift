//
//  SelectionView.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 16/07/2025.
//

import SwiftUI

struct AppListSelector: View {
    @Environment(\.dismiss) private var dismiss
    
    /**
     Bound item that is selected - this item will always appear at the top of the list regardless of the order of the items the view is instantiated with
     */
    @Binding var selectedItem: LookupItem?
    
    /**
     Items to be displayed for the user to select from. Set by the caller when constructing the view
     */
    var items: [LookupItem]
    
    /**
     Optional title to display at the top of the view
     */
    var title: String = ""
    
    /**
     Returns a reordered list with the selectedItem at the top of the list. The remaining items are in the order as specified by the order property
     */
    private var itemsInternal: [LookupItem] {
        guard let selectedItem = selectedItem, let index = items.firstIndex(of: selectedItem) else {
            return items  // If not found, return the array unchanged
        }
        
        var reordered = items
        let element = reordered.remove(at: index)
        reordered.insert(element, at: 0)
        
        return reordered
    }
    
    /**
     Main body
     */
    var body: some View {
        VStack {
            HStack {
                Text(title)
                    .font(.title)
                Spacer()
                Button(action: {
                    dismiss()
                })
                {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.gray)
                }
            }
            .padding()
            
            Divider()
            
            ScrollView {
                ForEach(itemsInternal) { item in
                    if let name = item.name, let id = item.id {
                        HStack {
                            Image(systemName: item.sfSymbolName)
                                .frame(width: 25)
                            Text(name)

                            Spacer()
                            
                            if id == selectedItem?.id {
                                Image(systemName: "checkmark")
                            }
                        }
                        .foregroundStyle(id == selectedItem?.id ? .orange : .primary)
                        .padding(.horizontal)
                        .padding(.bottom)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedItem = item
                            dismiss()
                        }
                    }
                }
                .padding(.top)
            }
            Spacer()
        }
        .padding()
    }
}

#Preview {
    @Previewable @State var selectedItem: LookupItem? = LookupItem(id: "2", name: "Hotel", imageRotation: nil, imageName: "HOTL")
    
    AppListSelector(selectedItem: $selectedItem, items: [
        LookupItem(id: "1", name: "Tent", imageRotation: nil, imageName: "carpenter"),
        LookupItem(id: "2", name: "Hotel", imageRotation: nil, imageName: "cabin"),
        LookupItem(id: "3", name: "Trail Angel", imageRotation: nil, imageName: "airline-seat-flat")
    ], title: "Where did you stay?")
}
