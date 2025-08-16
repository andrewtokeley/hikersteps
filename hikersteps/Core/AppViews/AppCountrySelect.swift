import SwiftUI

struct AppCountrySelect: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var searchText = ""
    @Binding var selectedCountryName: String
    @Binding var selectedCountryIdentifier: String
    
    var filteredCountries: [Country] {
        if searchText.isEmpty {
            return CountryManager.countries
        } else {
            return CountryManager.countries.filter { $0.countryName.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search countries", text: $searchText)
                        .textInputAutocapitalization(.none)
                        .disableAutocorrection(true)
                }
                .padding(8)
                .background(Color(.systemGray5))
                .cornerRadius(10)
                .padding([.horizontal, .top])
                
                List {
                    ForEach(filteredCountries) { country in
                        HStack {
                            Text(flag(for: country.identifier))
                            Text(country.countryName)
                            Spacer()
                            if country.countryName == self.selectedCountryName {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .contentShape(Rectangle()) // makes full row tappable
                        .onTapGesture {
                            self.selectedCountryName = country.countryName
                            self.selectedCountryIdentifier = country.identifier
                            dismiss()
                        }
                    }
                }
                .listStyle(.plain) // removes grouped background style
                .background(Color(.systemBackground)) // white in light mode, black in dark mode
                .scrollContentBackground(.hidden) // hides default list background
            }
        }
    }
    
    func flag(for countryCode: String) -> String {
        let base: UInt32 = 127397
        var flag = ""
        for scalar in countryCode.uppercased().unicodeScalars {
            if let scalarValue = UnicodeScalar(base + scalar.value) {
                flag.unicodeScalars.append(scalarValue)
            }
        }
        return flag
    }
}

#Preview {
    @Previewable @State var selectedCountryName: String = ""
    @Previewable @State var selectedCountryIdentifier: String = ""
    AppCountrySelect(selectedCountryName: $selectedCountryName, selectedCountryIdentifier: $selectedCountryIdentifier)
}
