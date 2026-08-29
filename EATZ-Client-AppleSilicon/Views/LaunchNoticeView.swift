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
    
    @State var showNavigationBarTitle = false
    
    let id: Int64
    let title: String
    let markdownContent: String
    let isForce: Bool
    
    private var navigationTitleLabel: String { title }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    contentView
                }
                .coordinateSpace(name: "scroll")
                VStack(spacing: 20) {
                    HStack {
                        if !isForce {
                            Button(action: {
                                SystemManager.shared.markNoticeAsViewed(id: id, doNotShowAgain: true)
                            }) {
                             Text("다시 보지 않기").frame(maxWidth: .infinity)
                            }.buttonStyle(RoundedButtonStyle(.secondary, .large))
                        }
                        Button(action: {
                            SystemManager.shared.markNoticeAsViewed(id: id, doNotShowAgain: false)
                        }) {
                         Text("확인").frame(maxWidth: .infinity)
                        }.buttonStyle(RoundedButtonStyle(.secondary, .large))
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.vertical, 20)
                .background(Color.backgroundPrimary)
            }
            .navigationTitle(navigationTitleLabel)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                titleToolbarItem
                dismissToolbarItem
            }
        }
    }
    
    private var titleToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text(navigationTitleLabel)
                .font(.headline)
                .opacity(showNavigationBarTitle ? 1 : 0)
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
    
    private var contentView: some View {
        VStack(spacing: 12) {
            Group {
                Text(title)
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(.black)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(
                        GeometryReader { proxy in
                            Color.clear
                                .onChange(of: proxy.frame(in: .named("scroll")).maxY) { _, maxY in
                                    let isShowing = maxY < 0
                                    if showNavigationBarTitle != isShowing {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            showNavigationBarTitle = isShowing
                                        }
                                    }
                                }
                        }.frame(height: 0)
                    )
                MarkdownView(markdownContent)
                    .padding(.vertical, 20)
            }
            .padding(.horizontal, 20)
        }
    }
}
