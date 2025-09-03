////
////  AppNumberUnitPicker.swift
////  hikersteps
////
////  Created by Andrew Tokeley on 22/07/2025.
////
//
//import SwiftUI
//
//struct AppNumberUnitPicker<T, U>: View where T: NumberUnit<U>, U: Hashable {
//    
//    @Environment(\.dismiss) private var dismiss
//    
//    /**
//     The NumberUnit bound to the view
//     */
//    @Binding var numberUnit: T
//    
//    /**
//     Internal state to track the selected number, only when OK is selected is the bound number set to this.
//     */
//    @State private var editNumberUnit: T
//    
//    /**
//     The title to display at the top of the view
//     */
//    var title: String
//    
//    /**
//     Optional text to place under the main title
//     */
//    var subTitle: String?
//    
//    private var onDidChange: ((T) -> Void)? = nil
//    
//    init (title: String, numberUnit: Binding<T>, subTitle: String? = nil) {
//        self._numberUnit = numberUnit
//        self.title = title
//        self.subTitle = subTitle
//        self.editNumberUnit = numberUnit.wrappedValue
//    }
//    
//    var body: some View {
//        VStack {
//            HStack {
//                Text(title)
//                    .font(.title)
//                Spacer()
//                Button(action: {
//                    dismiss()
//                })
//                {
//                    Image(systemName: "xmark.circle.fill")
//                        .imageScale(.medium)
//                        .font(.system(size: 30, weight: .thin))
//                        .foregroundColor(.secondary)
//                }
//            }
//            .padding(.top)
//            
//            if let subTitle = subTitle {
//                Text(subTitle)
//                    .font(.subheadline)
//                    .foregroundStyle(.secondary)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//            }
//            
//            Divider()
//            
//            HStack {
//                Picker(title, selection: $editNumberUnit.number) {
//                    ForEach(0..<100) { number in
//                        Text("\(number)").tag(number)
//                    }
//                }
//                .pickerStyle(.wheel)
//                .frame(height: 150)
//                
//                Text(editNumberUnit.unit.rawValue)
//                    .frame(height: 150)
//            }
//            
//            Spacer()
//            
//            Divider().padding()
//            
//            HStack {
//                
//                Button("Cancel") {
//                    dismiss()
//                }
//                .padding(.horizontal, 16)
//                .buttonStyle(.plain)
//                
//                Spacer()
//                
//                Button("OK") {
//                    // Write the edited values back to the bound properties
//                    //numberUnit = editNumberUnit
//                    numberUnit = T(editNumberUnit.number, editNumberUnit.unit)
//                    onDidChange?(numberUnit)
//                    dismiss()
//                }
//                .padding(.horizontal, 16)
//            }
//        }
//        .padding()
//    }
//    
//    func onDidChange(_ handler: ((T) -> Void)?) -> AppNumberUnitPicker {
//        var copy = self
//        copy.onDidChange = handler
//        return copy
//    }
//}
//
//#Preview {
//    @Previewable @State var distance: DistanceUnit = DistanceUnit(20, .km)
//    VStack {
//        Text(distance.description)
//        AppNumberUnitPicker(title: "Zero Days", numberUnit: $distance, subTitle: "Somethin to say about the numbers...")
//            .onChange(of: distance) { oldValue, newValue in
//                print("change")
//            }
//    }
//}
