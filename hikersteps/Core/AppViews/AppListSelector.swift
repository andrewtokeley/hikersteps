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
    @Binding var selectedItem: LookupItem
    
    /**
     Items to be displayed for the user to select from. Set by the caller when constructing the view
     */
    var items: [LookupItem]
    
    /**
     Optional title to display at the top of the view
     */
    var title: String = ""
    
    /**
     Flag to determine whether the user can select "No Selection"
     */
    var noSelection: Bool = false
    
    /**
     Returns a reordered list with the selectedItem at the top of the list. The remaining items are in the order as specified by the order property
     */
    private var itemsInternal: [LookupItem] {
        var reordered = items.sorted { $0.order < $1.order }
        if let selectedIndex = items.firstIndex(of: selectedItem) {
            let element = reordered.remove(at: selectedIndex)
            reordered.insert(element, at: 0)
        }
        
        if noSelection {
            reordered.insert(LookupItem.noSelection(), at: 0)
        }
        
        return reordered
    }
    
    init(items: [LookupItem], selectedItem: Binding<LookupItem>, title: String = "", noSelection: Bool = false) {
        self.items = items
        self.title = title
        self.noSelection = noSelection
        _selectedItem = selectedItem
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
                    if let id = item.id {
                        HStack {
                            
                            Image(systemName: item.imageName)
                                .frame(width: 25)
                        
                            
                            Text(item.name)

                            Spacer()
                            
                            if id == selectedItem.id {
                                Image(systemName: "checkmark")
                            }
                        }
                        .foregroundStyle(id == selectedItem.id ? .orange : .primary)
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
    @Previewable @State var selectedItem: LookupItem = LookupItem.noSelection()
    
    AppListSelector(
        items: [
            LookupItem(id: "1", name: "Tent", imageName: "carpenter"),
            LookupItem(id: "2", name: "Hotel", imageName: "cabin"),
            LookupItem(id: "3", name: "Trail Angel", imageName: "airline-seat-flat")],
        selectedItem: $selectedItem,
        title: "Where did you stay",
        noSelection: true)
}
