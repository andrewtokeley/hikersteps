//
//  HikeCard.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 30/07/2025.
//

import SwiftUI

struct JournalCardView: View {
    @Environment(\.dismiss) private var dismiss
    
    var journal: Journal
    
    @State private var showContextMenu: Bool = false
    @State private var showDeleteConfirmation: Bool = false
    
    private var onDeleteRequest: ((Journal) -> Void)? = nil

    init(journal: Journal) {
        self.journal = journal
    }
    
    var body: some View {
        HStack {
            if let url = URL(string: journal.heroImageUrl) {
                Group {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: ContentMode.fill)
                    } placeholder: {
                        Text("...")
                            .foregroundStyle(Color(.appLightGray))
                    }
                }
                .frame(width: 100, height: 100)
                .cornerRadius(10)
                .clipped()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(.appLightGray), lineWidth: 1)
                )
            } else {
                Image("pct")
                    .resizable()
                    .aspectRatio(contentMode: ContentMode.fill)
                    .frame(width: 100, height: 100)
                    .cornerRadius(10)
                    .clipped()
            }
            
            VStack(alignment: .leading) {
                Text(journal.name)
                    .foregroundStyle(.primary)
                    .font(.headline)
                Text(journal.startDate.formatted(.dateTime.day().month().year()))
                    .foregroundStyle(.primary)
                Group {
                    Text("Completed")
                    HStack {
                        Text(journal.statistics.totalDistanceWalked.description)
                        Text(" in ")
                        Text(journal.statistics.totalDays.description)
                    }
                }
                .foregroundStyle(.secondary)
                Spacer()
            }
            Spacer()
        }
        .frame(height: 110)
        .padding(.bottom)
        .onLongPressGesture {
            self.showContextMenu = true
        }
        .confirmationDialog("Options", isPresented: $showContextMenu, titleVisibility: .hidden) {
            Button("Delete Journal...", role: .destructive) {
                showDeleteConfirmation = true
            }
            Button("Cancel", role: .cancel) { }
        }
        .alert("Delete \(journal.name)", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {
                dismiss()
            }
            Button("Delete", role: .destructive) {
                onDeleteRequest?(self.journal)
            }
        } message: {
            Text("Are you sure you want to delete this Journal, including all journal entries and photos?. You can't undo this!")
        }
    }
    
    func onDeleteRequest(_ handler: ((Journal) -> Void)?) -> JournalCardView {
        var copy = self
        copy.onDeleteRequest = handler
        return copy
    }
}


#Preview {
    @Previewable @State var hike = Journal(uid: "abc", name: "TA 2021/22", description: "This is a test hike", startDate: Date())
    JournalCardView(journal: hike)
}
