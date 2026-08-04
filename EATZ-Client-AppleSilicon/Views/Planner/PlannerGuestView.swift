//
//  PlannerGuestView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/2/26.
//

import SwiftUI

struct PlannerGuestView: View {
    /// 지정한 날짜 범위입니다.
    /// - 모든 데이터 조회와 화면 표시에 사용하는 데이터 소스입니다.
    /// - 뷰 최초 진입 시점인 '오늘' 날짜를 시작으로 총 7일의 기간을 초기 날짜 범위 `dateRange`로 설정합니다.
    /// - 날짜 범위 내 플랜 목록은 뷰 모델 초기화 시점이 아닌, 뷰가 화면에 보여지는 시점(`.task` 등)에 `prepareDataIfNeeded`를 호출해 불러옵니다.
    @State var dateRange: (startDate: Date, endDate: Date) = PlannerViewModel.initialDateRange
    
    private var authManager: AuthManager
    
    init(_ authManager: AuthManager) {
        self.authManager = authManager
    }
    
    var body: some View {
        VStack {
            descriptionSection
            bottomActionSection
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            PlannerHeader(
                dateRange: dateRange,
                isDisabled: true)
        }
    }
    
    private var descriptionSection: some View {
        VStack {
            Spacer()
            VStack(spacing: 20) {
                Text("플래너")
                    .font(.system(size: 30, weight: .bold))
                Text("요리하고 싶은 레시피를 플래너의 원하는 날짜에 추가할 수 있어요. 플래너에 추가한 레시피를 요리하기 위해 필요한 재료와 도구를 체크리스트로 정리해드려요.")
                    .font(.system(size: 17, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.gray35)
            }
            .padding(20)
            Spacer()
        }
    }
    
    private var bottomActionSection: some View {
        VStack(spacing: 0) {
            HorizontalDivider()
            VStack(spacing: 12) {
                Image("handshake")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 48)
                    .foregroundStyle(Color.init(hex: "D1E7D7"))
                Button(action: authManager.requireAuthView) {
                    Text("이메일로 시작").frame(maxWidth: .infinity)
                }
                .buttonStyle(CapsuleLargeButtonStyle(appearance: .primary))
                .accentColor(Color.init(hex: "55C374"))
                Text("로그인 또는 가입 후 계속 진행할 수 있어요.")
                    .font(.system(size: 12, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.init(hex: "93A197"))
            }
            .padding(20)
        }
    }
}
