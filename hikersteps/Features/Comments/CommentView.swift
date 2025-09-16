//
//  CommentView.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 15/09/2025.
//

import SwiftUI

struct CommentView: View {
    @EnvironmentObject var auth: AuthenticationManager
    var comment: Comment
    var onDeleteRequest: (() -> Void)?
    
    var body: some View {
        VStack(alignment: .leading) {
            
            VStack(alignment: .leading) {
                Text(comment.username)
                    .font(.caption)
                    .bold()
                Text(comment.comment)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 15)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(15)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                Text(comment.createdDate.localisedTimeAgoDescription())
                    .font(.caption)
                    .padding(.leading)
                if (comment.uid == auth.user.uid) {
                    Text("Delete")
                        .underline()
                        .font(.caption)
                        .onTapGesture {
                            onDeleteRequest?()
                        }
                }
            }
        }
    }
    
    func onDeleteRequest(_ handler: (() -> Void)?) -> CommentView {
        var copy = self
        copy.onDeleteRequest = handler
        return copy
    }
}

#Preview {
    CommentView(comment: Comment.sample)
}
