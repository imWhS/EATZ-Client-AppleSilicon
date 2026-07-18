//
//  CommentItem.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 7/11/25.
//

import SwiftUI
    
struct CommentItem: View {
    let comment: Comment
    let permissions: Set<CommentPermission>
    
    var onBlock: (UserEssential) -> Void
    var onReport: (Comment) -> Void
    var onUpdate: (Int64) -> Void
    var onDelete: (Comment) -> Void
    
    init(
        _ comment: Comment,
        permissions: Set<CommentPermission>,
        onBlock: @escaping (UserEssential) -> Void,
        onReport: @escaping (Comment) -> Void,
        onUpdate: @escaping (Int64) -> Void,
        onDelete: @escaping (Comment) -> Void)
    {
        self.comment = comment
        self.permissions = permissions
        self.onBlock = onBlock
        self.onReport = onReport
        self.onUpdate = onUpdate
        self.onDelete = onDelete
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .top, spacing: 12) {
                ProfileImageView(imageUrl: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQLiKmxv4M0fkn7aA-Sh4V1kA0LO_KgAQp9NHsaEQ6F918AGzmeT8qdhZc0lpM3jhy2u6c&usqp=CAU", size: 32)
                VStack(spacing: 8) {
                    VStack(spacing: 8) {
                        HStack(spacing: 8) {
                            Text(comment.author.username)
                                .font(.system(size: 12, weight: .semibold))
                            Spacer()
                            Text(comment.createdAt.formattedRelative)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(.gray)
                        }
                        Text(comment.content)
                            .font(.system(size: 17, weight: .medium))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.leading, 0)
                    .padding(.trailing, 20)
                    
                    if !permissions.isEmpty {
                        CommentItemInteractionView(
                            permissions: permissions,
                            onBlock: { onBlock(comment.author) },
                            onReport: { onReport(comment) },
                            onUpdate: { onUpdate(comment.id) },
                            onDelete: { onDelete(comment) }
                        )
                        .padding(.horizontal, 12)
                    }
                    
                    HorizontalDivider(padding: 0)
                        .padding(.trailing, 20)
                        .padding(.top, !permissions.isEmpty ? 4 : 12)
                }
            }
            .padding(.leading, 20)
        }
        .padding(.top, 20)
    }
}

private struct CommentItemInteractionView: View {
    let permissions: Set<CommentPermission>
    let onBlock: () -> Void
    let onReport: () -> Void
    let onUpdate: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            Spacer()
            if permissions.contains(.block) {
                Button("작성자 차단", action: onBlock).buttonStyle(SmallBorderlessButtonStyle())
            }
            if permissions.contains(.report) {
                Button("신고", action: onReport).buttonStyle(SmallBorderlessButtonStyle())
            }
            if permissions.contains(.update) {
                Button("수정", action: onUpdate).buttonStyle(SmallBorderlessButtonStyle())
            }
            if permissions.contains(.delete) {
                Button("삭제", action: onDelete).buttonStyle(SmallBorderlessButtonStyle())
            }
//            if permissions.contains(.hide) {
//                Button("숨김", action: { print("숨기기") }).buttonStyle(SmallBorderlessButtonStyle())
//            }
        }
    }
}
