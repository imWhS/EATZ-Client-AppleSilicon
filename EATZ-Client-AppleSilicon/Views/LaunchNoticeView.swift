//
//  LaunchNoticeView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 8/6/26.
//

import SwiftUI
import MarkdownView

struct LaunchNoticeView: View {
    @Environment(\.dismiss) private var dismiss
    
    let id: Int64
    let title: String
    let markdownContent: String
    let isForce: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    MarkdownView(markdownContent)
                        .padding(.vertical, 0)
                        .padding(.horizontal, 20)
                }
                VStack(spacing: 20) {
                    HStack {
                        if !isForce {
                            Button(action: {
                                SystemManager.shared.markNoticeAsViewed(id: id, doNotShowAgain: true)
                            }) {
                             Text("다시 보지 않기").frame(maxWidth: .infinity)
                            }.buttonStyle(CapsuleLargeButtonStyle(appearance: .secondary))
                        }
                        Button(action: {
                            SystemManager.shared.markNoticeAsViewed(id: id, doNotShowAgain: false)
                        }) {
                         Text("확인").frame(maxWidth: .infinity)
                        }.buttonStyle(CapsuleLargeButtonStyle(appearance: .secondary))
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.vertical, 20)
                .background(Color.backgroundPrimary)
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                dismissToolbarItem
            }
        }
    }
    
    private var dismissToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                SystemManager.shared.markNoticeAsViewed(id: id, doNotShowAgain: false)
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 17, weight: .semibold))
            }
        }
    }
}
