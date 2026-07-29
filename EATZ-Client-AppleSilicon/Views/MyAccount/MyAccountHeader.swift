//
//  MyAccountHeader.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/2/26.
//

import SwiftUI

struct MyAccountHeader: View {
    let member: CurrentUser?
    let onEditProfileTapped: (() -> Void)?
    let onRegisterRecipeTapped: (() -> Void)?
    let onSettingsTapped: (() -> Void)?
    
    var imageUrl: String { member?.imageUrl ?? "" }
    
    var username: String { member?.username ?? "—" }
    
    init(_ member: CurrentUser?, onEditProfileTapped: (() -> Void)?, onRegisterRecipeTapped: (() -> Void)?, onSettingsTapped: (() -> Void)?) {
        self.member = member
        self.onEditProfileTapped = onEditProfileTapped
        self.onRegisterRecipeTapped = onRegisterRecipeTapped
        self.onSettingsTapped = onSettingsTapped
    }
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                toolbarSection
                profileSection
                registerRecipeView
            }
            .padding(.vertical, 10)
            HorizontalDivider()
        }
    }
    
    private var toolbarSection: some View {
        HStack {
            Spacer()
            Button(action: onSettingsTapped ?? {}) {
                HStack(spacing: 4) {
                    Image(systemName: "gearshape")
                    Text("설정 및 정보")
                    Image("arrow-right-6.8")
                }
            }
            .buttonStyle(SmallBorderlessButtonStyle())
        }
        .padding(.trailing, 12)
        .padding(.vertical, 4)
    }
    
    private var profileSection: some View {
        HStack(spacing: 8) {
            leftSideProfileImageView
            rightSideProfileDetailView
        }
        .padding(.vertical, 10)
    }
    
    private var leftSideProfileImageView: some View {
        HStack {
            ProfileImageView(imageUrl: imageUrl, size: 80)
        }
        .padding(.leading, 20)
    }
    
    private var rightSideProfileDetailView: some View {
        Button(action: onEditProfileTapped ?? {}) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(username)
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(Color.black)
                    Text("프로필 관리")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.gray20)
                }
                Spacer()
                ArrowDownCircled20()
            }
            .padding(12)
        }
        .buttonStyle(SquareHighlightButtonStyle(cornerRadius: 12))
        .padding(.trailing, 8)
        .disabled(member == nil)
        .opacity(member == nil ? 0.5 : 1)
    }
    
    private var registerRecipeView: some View {
        VStack {
            Button(action: onRegisterRecipeTapped ?? {}) {
                Text("새 레시피")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(BigRoundedButtonStyle(type: member == nil ? .disabled : .primary))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
}
