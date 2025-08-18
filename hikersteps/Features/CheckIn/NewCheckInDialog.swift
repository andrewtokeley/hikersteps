//
//  NewCheckInDialog.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 10/07/2025.
//

import SwiftUI

struct NewCheckInDialog: View {
    @Environment(\.dismiss) private var dismiss
    
    private var onCancel: (() -> Void)?
    private var onConfirm: ((Date) -> Void)?
    private var onCreated: ((CheckIn) -> Void)?
    private var isDateAvailable: ((Date) -> Bool)?
    
    @State private var canConfirm: Bool = false
    
    @StateObject private var viewModel: ViewModel
    
    // The CheckIn that gets created and saved
    @State private var checkIn: CheckIn = CheckIn.nilValue
    
    @State private var notes: String = ""
    @State private var title: String = ""
    @State private var journalDate: Date
    
    var location: Coordinate
    var info: String? = nil
    var journal: Journal
    
    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: ViewModel(checkInService: CheckInService()))
        _journalDate = State(initialValue: Date())
        self.journal = .nilValue
        self.location = .init(latitude: 0, longitude: 0)
    }
    
    init(journal: Journal,
         proposedDate: Date = Date(),
         info: String? = nil,
         location: Coordinate) {
        
        // default constructor
        _viewModel = StateObject(wrappedValue: ViewModel(checkInService: CheckInService()))

        _journalDate = State(initialValue: proposedDate)
        self.journal = journal
        self.location = location
        self.info = info
    }
    
    var body: some View {
        VStack (alignment: .leading) {
            HStack (alignment: .top) {
                TextField("Add Title", text: $title)
                    .padding(.bottom)
                    .font(.title)
                Spacer()
                Button(action: {
                    onCancel?()
                    dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .imageScale(.medium)
                        .font(.system(size: 30, weight: .thin))
                        .foregroundColor(.secondary)
                }
            }
            HStack {
                DatePicker("", selection: $journalDate, displayedComponents: .date)
                    .labelsHidden()
                    .datePickerStyle(.compact)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(canConfirm ? .gray : .red, lineWidth: 1)
                    )
                    .onChange(of: journalDate) {
                        // check if this date is available
                        self.canConfirm = isDateAvailable?(journalDate) ?? false
                    }
                    .onAppear {
                        self.canConfirm = isDateAvailable?(journalDate) ?? false
                    }
                if (!canConfirm) {
                    Text("You've already written a journal entry for that day.")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
            AppTextEditor(text: $notes, placeholder: "Thoughts of the day...")
                .frame(height: 150)
                .padding(.top,1)

            if let info
                = info {
                Text(info)
                    .font(.subheadline)
                    .padding(.top)
            }
            
            HStack {
                
                AppCapsuleButton("Cancel") {
                    dismiss()
                }
                .capsuleStyle(.white)
                Spacer()
                AppCapsuleButton("Create") {
                    Task {
                        do {
                            if let journalId = journal.id {
                                self.checkIn = try await viewModel.addCheckIn(title: title, date: journalDate, notes: notes, journalId: journalId)
                                onCreated?(self.checkIn)
                                dismiss()
                            }
                        } catch {
                            ErrorLogger.shared.log(error)
                        }
                    }
                    
                }
                .capsuleStyle(.filled)
                .disabled(!canConfirm)
            }
            .padding(.top, 30)
            Spacer()
        }
        .padding()
    }
    
    func onCancel(_ handler: (() -> Void)?) -> NewCheckInDialog {
        var copy = self
        copy.onCancel = handler
        return copy
    }
    
    func onCreated(_ handler: ((CheckIn) -> Void)?) -> NewCheckInDialog {
        var copy = self
        copy.onCreated = handler
        return copy
    }
    
    func onConfirm(_ handler: ((Date) -> Void)?) -> NewCheckInDialog {
        var copy = self
        copy.onConfirm = handler
        return copy
    }
    
    func isDateAvailable(_ handler: ((Date) -> Bool)?) -> NewCheckInDialog {
        var copy = self
        copy.isDateAvailable = handler
        return copy
    }
}

#Preview {
    NewCheckInDialog(viewModel: NewCheckInDialog.ViewModel(checkInService: CheckInService.Mock()))
        .isDateAvailable { date in
            return date.compare(Date()) == .orderedAscending
    }
}
