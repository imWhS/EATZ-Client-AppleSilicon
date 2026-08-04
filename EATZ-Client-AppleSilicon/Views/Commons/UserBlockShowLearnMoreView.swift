//
//  UserBlockShowLearnMoreView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/17/26.
//

import SwiftUI

struct UserBlockShowLearnMoreView: View {
    @Environment(\.dismiss) private var dismiss
    @State var showNavigationBarTitle = false
    
    private var titleLabel: String = "사용자 차단"
    private var subtitleLabel: String = "더 알아보기"
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    scrollTracker
                    normalStateHeader
                    bodySection
                }
            }
            .coordinateSpace(name: "scroll")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                dismissToolbarItem
                titleToolbarItem
            }
        }
        
    }
    
    private var titleToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            VStack {
                Text(titleLabel)
                    .font(.system(size: 17, weight: .semibold))
                Text(subtitleLabel)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.gray35)
            }
            .opacity(showNavigationBarTitle ? 1 : 0)
        }
    }
    
    private var dismissToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 17, weight: .semibold))
            }
        }
    }
    
    private var normalStateHeader: some View {
        VStack {
            Image(systemName: "nosign")
                .symbolVariant(.fill)
                .font(.system(size: 40))
                .padding(6)
                .foregroundColor(.init(hex: "DC381F"))
                .background(Color.black.opacity(0.075))
                .clipShape(Circle())
            VStack(spacing: 8) {
                Text(titleLabel)
                    .font(.system(size: 30, weight: .bold))
                Text(subtitleLabel)
                    .font(.system(size: 17, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.gray35)
            }
            .padding(20)
        }
    }
    
    @ViewBuilder
    private var bodySection: some View {
        VStack(spacing: 20) {
            HorizontalDivider(padding: 0)
            
            VStack(alignment: .leading, spacing: 20) {
                createInfoRow(
                    icon: "eye.slash",
                    text: "차단된 사용자가 작성한 레시피와 댓글, 평가 등의 콘텐츠를 포함한 모든 활동이 더 이상 회원님에게 보이지 않아요."
                )
                createInfoRow(
                    icon: "bell.slash",
                    text: "차단된 사용자에게 차단 여부를 알리지 않아요."
                )
                createInfoRow(
                    icon: "clock.arrow.circlepath",
                    text: "단, 회원님의 개인 활동 기록을 확인하는 것과 관련 있는 화면에서는 맥락을 위해 회원님이 차단하기 전의 연관 활동이 일부 보일 수 있어요."
                )
                createInfoRow(
                    icon: "chart.bar",
                    text: "차단한 사용자의 화면 노출만 제한해요. 이 사용자에 의해 집계된 조회 수, 평가 점수, 평가 수, 댓글 수, 좋아요 수 등의 활동 지표는 유지되며, 각 항목 별 통계에도 반영돼요."
                )
                createInfoRow(
                    icon: "gearshape",
                    text: "<내 계정 → 환경 설정 → 차단한 사용자 관리>에서 언제든지 차단한 사용자 목록을 확인하고, 특정 사용자를 차단 해제할 수 있어요."
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
    }
    
    private func actionButton(title: String, type: CapsuleLargeButtonAppearance, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(CapsuleLargeButtonStyle(appearance: type))
        .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    private func createInfoRow(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 18) {
            ZStack {
                Circle()
                    .foregroundStyle(Color.black.opacity(0.075))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .symbolVariant(.fill)
                    .font(.system(size: 20))
                    .foregroundColor(.secondary)
                    .frame(width: 20, alignment: .center)
            }
            VStack(alignment: .leading, spacing: 20) {
                Text(text)
                    .font(.system(size: 17, weight: .medium))
                    .frame(maxWidth: .infinity, minHeight: 40, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                HorizontalDivider(padding: 0)
            }
        }
    }
    
    private var scrollTracker: some View {
        GeometryReader { proxy in
            let offset = proxy.frame(in: .named("scroll")).minY
            Color.clear
                .onChange(of: offset) { _, offset in
                    let shouldShow = offset < -140
                    if showNavigationBarTitle != shouldShow {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showNavigationBarTitle = shouldShow
                        }
                    }
                }
        }
        .frame(height: 0)
    }
}
