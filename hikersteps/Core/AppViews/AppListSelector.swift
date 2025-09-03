//
//  SelectionView.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 16/07/2025.
//

import SwiftUI

struct SelectableItem: Identifiable {
    var id: String
    var name: String
    var order: Double = 0.0
    var imageName: String? = nil
    
    static var noSelection: SelectableItem {
        .init(id: UUID().uuidString, name: "No Selection")
    }
    
    init(id: String, name: String, order: Double = 0.0, imageName: String? = nil) {
        self.id = id
        self.order = order
        self.name = name
        self.imageName = imageName
    }
    
    /**
     Custom equatable implementation that ignores the tag
     */
//    static func == (lhs: SelectableItem, rhs: SelectableItem) -> Bool {
//        return
//            lhs.id == rhs.id &&
//            lhs.order == rhs.order &&
//            lhs.name == rhs.name &&
//            lhs.imageName == rhs.imageName
//    }
    
}

struct AppListSelector<T: Equatable>: View {
    @Environment(\.dismiss) private var dismiss
    
    /**
     Bound item that is selected - this item will always appear at the top of the list regardless of the order of the items the view is instantiated with
     */
    @Binding var selectedItem: T
    
    @State private var selectedIndex: Int = -1
    
    /**
     Raw items supplied by the client
     */
    var items: [T]
    
    /**
     Internal representation for the list - constructed using the closure provided in init.
     */
    private var _items: [SelectableItem]
    
    /**
     Optional title to display at the top of the view
     */
    var title: String = ""
    
    /**
     Flag to determine whether the user can select "No Selection"
     */
    var noSelection: Bool = false
    
    init(items: [T], selectedItem: Binding<T>, title: String = "", noSelection: Bool = false, itemsConverter: @escaping (T) -> SelectableItem) {

        self.items = items
        
        // create internal representation of items using converter
        self._items = items.map { itemsConverter($0) }
        
        // add noSelection
        //
        // order by the internal representation and keep the order of the raw items in sync
        let combined = zip(self.items, self._items).sorted { $0.1.order < $1.1.order }
        
        // copy ordered sets back
        self.items = combined.map { $0.0 }
        self._items = combined.map { $0.1 }
        
        self.title = title
        self.noSelection = noSelection
        _selectedItem = selectedItem
        
        if let initialIndex = items.firstIndex(where: { $0 == selectedItem.wrappedValue }) {
            self._selectedIndex = State(initialValue: initialIndex)
        }
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
                        .imageScale(.medium)
                        .font(.system(size: 30, weight: .thin))
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            
            Divider()
            
            ScrollView {
                ForEach(Array(_items.enumerated()), id: \.offset) { index, item in
                    HStack {
                        if let imageName = item.imageName {
                            Image(systemName: imageName)
                            .frame(width: 25) }
                        else {
                            EmptyView()
                                .frame(width: 25)
                        }
                        
                        Text(item.name)
                        
                        Spacer()
                        
                        if index == selectedIndex {
                            Image(systemName: "checkmark")
                        }
                    }
                    .foregroundStyle(index == selectedIndex ? .orange : .primary)
                    .padding(.horizontal)
                    .padding(.bottom)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        // select the item's index
                        self.selectedIndex = index
                        
                        // select the selected item
                        self.selectedItem = self.items[index]

                        dismiss()
                    }
                }
                .padding(.top)
            }
            Spacer()
        }
        .padding()
    }
}

//struct AppListSelector_Previews: PreviewProvider {
//
//    static var previews: some View {
//
//        @State var selectedItem: LookupItem = LookupItem(id: "2", name: "Second")
//        @State var items: [LookupItem] = [
//            LookupItem(id: "1", name: "First"),
//            LookupItem(id: "2", name: "Second"),
//            LookupItem(id: "3", name: "Third"),
//            LookupItem(id: "4", name: "Fourth"),
//            LookupItem(id: "5", name: "Fifth"),
//        ]
//        
//        return VStack {
//            Text(selectedItem.name)
//            AppListSelector<LookupItem>(
//                items: items,
//                selectedItem: $selectedItem,
//                title: "Select a Disance",
//                noSelection: true
//            ) {
//                return SelectableItem(id: $0.id!, name: $0.name)
//            }
//        }
//    }
//}

#Preview {
//    @Previewable @State var selectedItem: LookupItem = LookupItem(id: "2", name: "Second")
//    @Previewable @State var items: [LookupItem] = [
//        LookupItem(id: "1", name: "First"),
//        LookupItem(id: "2", name: "Second"),
//        LookupItem(id: "3", name: "Third"),
//        LookupItem(id: "4", name: "Fourth"),
//        LookupItem(id: "5", name: "Fifth")
//    ]
//    
//    VStack {
//        Text(selectedItem.name)
//        AppListSelector<LookupItem>(
//            items: items,
//            selectedItem: $selectedItem,
//            title: "Select a lookup",
//            noSelection: true
//        )
//        {
//            return SelectableItem(id: $0.id!, name: $0.name)
//        }
//    }
//    

    @Previewable @State var selectedItem: Measurement<UnitLength> = .init(value: 20, unit: .kilometers)
    @Previewable @State var items: [Measurement<UnitLength>] = [
        .init(value: 20, unit: .kilometers),
        .init(value: 30, unit: .kilometers),
        .init(value: 40, unit: .kilometers),
        .init(value: 50, unit: .kilometers),
    ]
    
    VStack {
        Text(selectedItem.description)
        AppListSelector<Measurement<UnitLength>>(
            items: items,
            selectedItem: $selectedItem,
            title: "Select a Disance",
            noSelection: true
        )
        {
            return SelectableItem(id: UUID().uuidString, name: $0.description)
        }
    }
}
