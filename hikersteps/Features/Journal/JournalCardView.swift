//
//  HikeCard.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 30/07/2025.
//

import SwiftUI
import NukeUI
import Nuke

struct JournalCardView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var auth: AuthenticationManager
    
    var journal: Journal?
    
    @State private var showContextMenu: Bool = false
    @State private var showDeleteConfirmation: Bool = false
    
    private var sourceUrl: URL? {
        if let image = journal?.heroImageUrl {
            return URL(string: image)
        }
        return URL(string:"https://images.unsplash.com/photo-1679431627223-3c229ff1fe06?q=80&w=1548&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D")
    }
    
    private var onDeleteRequest: ((Journal) -> Void)? = nil
    private var onCreateRequest: (() -> Void)? = nil
    
    init(journal: Journal?) {
        self.journal = journal
    }
    
    var body: some View {
        ZStack {
            if let source = self.sourceUrl {
                Group {
                    LazyImage(source: source) { state in
                        if let image = state.image {
                            image
                                .resizingMode(.aspectFill)
                        } else if state.error != nil {
                            Color.red // Error state
                        } else {
                            ProgressView()
                                .scaleEffect(1.2)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color.gray.opacity(0.1))
                                .tint(.accentColor)
                                .styleBorderLight(focused: true)
                        }
                    }
                }
                .cornerRadius(20)
            }
            VStack {
                Spacer()
                LinearGradient(
                    gradient: Gradient(colors: [Color.black.opacity(0.8), Color.clear]),
                    startPoint: .bottom,
                    endPoint: .top
                )
                .frame(height: 250)
                .cornerRadius(20)
            }
            
            VStack {
                Spacer()
                if let journal = self.journal {
                    Text(journal.name)
                        .foregroundStyle(.primary)
                        .bold()
                        .font(.title)
                    Text(journal.startDate.formatted(.dateTime.day().month().year()))
                        .font(.headline)
                    Text(auth.user.username)
                        .font(.headline)
                } else {
                    Text("Journal Your Next Big Adventure!")
                        .foregroundStyle(.primary)
                        .bold()
                        .font(.title)
                        .multilineTextAlignment(.center)
                    AppCapsuleButton("Create") {
                        print("create")
                        onCreateRequest?()
                    }
                }
                
            }
            .padding(.bottom, 50)
            .foregroundStyle(.white)
        }
    }
    
    func onDeleteRequest(_ handler: ((Journal) -> Void)?) -> JournalCardView {
        var copy = self
        copy.onDeleteRequest = handler
        return copy
    }
    
    func onCreateRequest(_ handler: (() -> Void)?) -> JournalCardView {
        var copy = self
        copy.onCreateRequest = handler
        return copy
    }
}


#Preview {
//    @Previewable @State var hike = Journal(uid: "abd", name: "Tokes TAS", description: "desc", startDate: Date())
    @Previewable @State var hike = Journal.sample
    JournalCardView(journal: hike)
        .environmentObject(AuthenticationManager.forPreview())
}
