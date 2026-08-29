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
    
    let action: (Comment, CommentItemAction) -> Void
    
    init(
        _ comment: Comment,
        _ permissions: Set<CommentPermission>,
        _ action: @escaping (Comment, CommentItemAction) -> Void)
    {
        self.comment = comment
        self.permissions = permissions
        self.action = action
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .top, spacing: 12) {
                ProfileImageView(comment.author.imageUrl, size: 32)
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
                        HStack(spacing: 8) {
                            Spacer()
                            if permissions.contains(.block) {
                                Button("작성자 차단", action: { action(comment, .block) })
                                    .buttonStyle(SmallBorderlessButtonStyle())
                            }
                            if permissions.contains(.report) {
                                Button("신고", action: { action(comment, .report) })
                                    .buttonStyle(SmallBorderlessButtonStyle())
                            }
                            if permissions.contains(.update) {
                                Button("수정", action: { action(comment, .update) })
                                    .buttonStyle(SmallBorderlessButtonStyle())
                            }
                            if permissions.contains(.delete) {
                                Button("삭제", action: { action(comment, .delete) })
                                    .buttonStyle(SmallBorderlessButtonStyle(status: .danger))
                            }
//                                if permissions.contains(.hide) {
//                                    Button("숨김", action: { print("숨기기") })
//                                }
                        }
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

enum CommentItemAction {
    case block, report,update, delete, hide
}
