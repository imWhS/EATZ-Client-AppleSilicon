//
//  RecipeDetailInfoSection.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 2/20/26.
//

import SwiftUI

struct RecipeDetailInfoSection: View {
    let recipe: Recipe
    let onRatingTapped: (Int64) -> Void
    let onCommentTapped: (Int64) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            RecipeDetailInfoDescriptionView(
                description: recipe.description,
                createdAt: recipe.createdAt,
                authorUsername: recipe.author.username,
                authorImageUrl: recipe.author.imageUrl,
                authorBio: recipe.author.bio)
            RecipeDetailInfoReactionView(
                recipe.id,
                ratingSummary: recipe.ratingIndicatorSummary,
                commentCount: recipe.commentCount,
                commentEnabled: recipe.commentEnabled,
                onRatingTapped: onRatingTapped,
                onCommentTapped: onCommentTapped)
        }
    }
}

struct RecipeDetailInfoDescriptionView: View {
//    let recipe: Recipe
    let description: String
    let createdAt: Date
    
    let authorUsername: String
    let authorImageUrl: String?
    let authorBio: String?
    
    var body: some View {
        VStack(spacing: 0) {
            HorizontalDivider()
            VStack(spacing: 0) {
                titleSection
                bodySection
            }
            .padding(.vertical, 10)
        }
    }
    
    private var titleSection: some View {
        RecipeDetailTitle("상세 정보")
            .padding(.vertical, 10)
    }
    
    private var bodySection: some View {
        VStack(spacing: 0) {
            Group {
                descriptionView
                authorView
            }
            .padding(.vertical, 10)
        }
    }
    
    private var descriptionView: some View {
        Text(description)
            .font(.system(size: 17))
            .frame(maxWidth: .infinity, alignment: .leading)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 20)
    }
    
    private var authorView: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 16) {
                Group {
                    HStack(spacing: 20) {
                        HStack(spacing: 10) {
                            ProfileImageView(imageUrl: authorImageUrl, size: 40)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("레시피 작성자")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(Color.gray20)
                                HStack {
                                    Text(authorUsername)
                                        .font(.system(size: 17, weight: .semibold))
                                    DotSeparatorView()
                                    Text(createdAt.formattedRelative)
                                        .font(.system(size: 17, weight: .medium))
                                }
                            }
                            Spacer()
                        }
                    }
                    
                    if let bio = authorBio {
                        Text(bio)
                            .font(.system(size: 17, weight: .medium))
                            .lineLimit(nil)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .foregroundStyle(.black)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }
}

struct RecipeDetailInfoAuthorViewN: View {
    let recipe: Recipe
    
    var body: some View {
        VStack(spacing: 0) {
            HorizontalDivider()
            VStack(alignment: .leading, spacing: 16) {
                Group {
                    HStack(spacing: 20) {
                        HStack(spacing: 10) {
                            ProfileImageView(imageUrl: recipe.author.imageUrl, size: 40)
                            authorProfileLabeledValueView(
                                username: recipe.author.username,
                                createdAt: recipe.createdAt)
                        }
                    }
                    
                    if let bio = recipe.author.bio {
                        Text(bio)
                            .font(.system(size: 17, weight: .medium))
                            .lineLimit(nil)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .foregroundStyle(.black)
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.vertical, 20)
        }
    }
    
    private func authorProfileLabeledValueView(username: String, createdAt: Date) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(username)
                .font(.system(size: 12, weight: .semibold))
            Text(createdAt.formattedRelative)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.gray20)
        }
    }
}

struct RecipeDetailInfoReactionView: View {
    let recipeId: Int64
    let ratingSummary: RatingIndicatorSummary?
    let commentCount: Int?
    let commentEnabled: Bool
    
    let onRatingTapped: (Int64) -> Void
    let onCommentTapped: (Int64) -> Void
    
    init(
        _ recipeId: Int64,
        ratingSummary: RatingIndicatorSummary?,
        commentCount: Int?,
        commentEnabled: Bool,
        onRatingTapped: @escaping (Int64) -> Void,
        onCommentTapped: @escaping (Int64) -> Void)
    {
        self.recipeId = recipeId
        self.ratingSummary = ratingSummary
        self.commentCount = commentCount
        self.commentEnabled = commentEnabled
        self.onRatingTapped = onRatingTapped
        self.onCommentTapped = onCommentTapped
    }
    
    private var isInitialCommentDisabled: Bool {
        commentCount == 0 && !commentEnabled
    }
    
    private var ratingAverageScoreLabel: String? {
        if let rating = ratingSummary,
           let averageScore = rating.averageScore {
            return String(format: "%.1f", averageScore) + " / 5"
        }
        else { return nil }
    }
    
    private var ratingCountLabel: String? {
        if let rating = ratingSummary, rating.count > 0 { return "\(rating.count)" }
        else { return nil }
    }
    
    private var commentCountLabel: String? {
        if let count = commentCount, count > 0 { return "\(count)" }
        else { return nil }
    }
    
    private var commentGuideLabel: String {
        if isInitialCommentDisabled {
            return "댓글이\n비활성화됐어요."
        } else {
            return "첫 댓글을\n남겨보세요."
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HorizontalDivider()
            VStack(spacing: 0) {
                titleSection
                bodySection
            }
            .padding(.vertical, 10)
        }
    }
    
    private var titleSection: some View {
        RecipeDetailTitle("반응")
            .padding(.vertical, 10)
    }
    
    private var bodySection: some View {
        VStack(spacing: 0) {
            Group {
                HStack(spacing: 8) {
                    ratingButton
                    commentButton
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 10)
    }
    
    private var ratingButton: some View {
        RecipeDetailReactionButton(
            icon: "recipe-rating",
            title: "평가",
            type: .normal,
            action: { onRatingTapped(recipeId) }) {
                HStack(spacing: 20) {
                    if let ratingAverageScoreLabel = ratingAverageScoreLabel,
                       let ratingCountLabel = ratingCountLabel {
                        VerticalLabeledValueView(
                            label: "평균 점수",
                            value: ratingAverageScoreLabel,
                            style: .secondary)
                        VerticalLabeledValueView(
                            label: "평가한 사람 수",
                            value: ratingCountLabel,
                            style: .secondary)
                    } else {
                        VStack {
                            Spacer()
                            Text("아직 평가한 사람이 없어요.\n첫 평가를 남겨보세요.")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(Color.gray20)
                        }
                    }
                }
            }
    }
    
    private var commentButton: some View {
        RecipeDetailReactionButton(
            icon: "recipe-comment",
            title: "댓글",
            maxWidth: 80,
            type: isInitialCommentDisabled ? .disabled : .normal,
            action: { onCommentTapped(recipeId) }) {
                HStack(spacing: 20) {
                    if let commentCountLabel = commentCountLabel {
                        VerticalLabeledValueView(
                            label: "댓글 수",
                            value: commentCountLabel,
                            style: .secondary)
                    } else {
                        VStack {
                            Spacer()
                            Text(commentGuideLabel)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(Color.gray20)
                        }
                    }
                }
        }
    }
}

private struct RecipeDetailReactionButton<Container: View>: View {
    let icon: String
    let title: String
    let maxWidth: CGFloat?
    let type: RecipeDetailReactionButtonStyle.RecipeDetailReactionButtonType
    let action: () -> Void
    @ViewBuilder let bottomContainer: Container
    
    init(
        icon: String,
        title: String,
        maxWidth: CGFloat? = nil,
        type: RecipeDetailReactionButtonStyle.RecipeDetailReactionButtonType,
        action: @escaping () -> Void,
        @ViewBuilder bottomContainer: () -> Container)
    {
        self.icon = icon
        self.title = title
        self.maxWidth = maxWidth
        self.type = type
        self.action = action
        self.bottomContainer = bottomContainer()
    }
    
    var body: some View {
        Button(action: type == .disabled ? {} : action) {
            HStack {
                VStack(alignment: .leading, spacing: 12) {
                    topContainer
                    bottomContainer
                }
            }
            .frame(maxWidth: maxWidth, minHeight: 68, alignment: .top)
        }
        .buttonStyle(RecipeDetailReactionButtonStyle(type: type))
    }
    
    private var topContainer: some View {
        HStack(spacing: 4) {
            Group {
                Image(icon)
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                Spacer()
                Image("arrow-right-14")
            }
            .foregroundStyle(Color.accentColor)
        }
    }
}

private struct RecipeDetailReactionButtonStyle: ButtonStyle {
    var type: RecipeDetailReactionButtonType
    
    func makeBody(configuration: Configuration) -> some View {
        let backgroundColor: Color
        let foregroundColor: Color
        
        switch type {
        case .normal:
            backgroundColor = Color.buttonSecondary
            foregroundColor = .accentColor
        case .disabled:
            backgroundColor = Color.buttonSecondary
            foregroundColor = .accentColor
        }
        
        return configuration.label
            .padding(16)
            .foregroundStyle(foregroundColor)
            .background(backgroundColor)
            .cornerRadius(12)
            .scaleEffect(type != .disabled && configuration.isPressed ? 0.965 : 1.0)
            .opacity(type != .disabled && configuration.isPressed ? 0.5 : 1.0)
            .animation(
                configuration.isPressed ? .easeInOut(duration: 0.1) : .easeInOut(duration: 0.25),
                value: configuration.isPressed
            )
            .opacity(type == .disabled ? 0.5 : 1)
            .disabled(type == .disabled)
    }
    
    enum RecipeDetailReactionButtonType {
        case normal
        case disabled
    }
}
