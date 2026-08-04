//
//  TagCloudView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 7/4/25.
//

import SwiftUI

struct TagCloudLayout: Layout {
    let spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        var width: CGFloat = 0
        var height: CGFloat = 0
        var currentRowHeight: CGFloat = 0
        var currentRowWidth: CGFloat = 0
        let maxWidth = proposal.width ?? .infinity

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentRowWidth + size.width > maxWidth {
                height += currentRowHeight + spacing
                currentRowWidth = 0
                currentRowHeight = 0
            }
            currentRowWidth += size.width + spacing
            currentRowHeight = max(currentRowHeight, size.height)
            width = max(width, currentRowWidth)
        }
        height += currentRowHeight

        return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x: CGFloat = bounds.minX
        var y: CGFloat = bounds.minY
        var currentRowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX {
                x = bounds.minX
                y += currentRowHeight + spacing
                currentRowHeight = 0
            }
            subview.place(
                at: CGPoint(x: x, y: y),
                proposal: ProposedViewSize(width: size.width, height: size.height)
            )
            x += size.width + spacing
            currentRowHeight = max(currentRowHeight, size.height)
        }
    }
}

// MARK: - Tag Cloud View
struct RecipeTagCloudView: View {
    let tags: [RecipeTag]

    var body: some View {
        TagCloudLayout(spacing: 6) {
            ForEach(Array(tags.enumerated()), id: \.1.id) { (index, tag) in
                HStack(spacing: 6) {
                    Text(tag.name)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.black)
                    if index < tags.count - 1 {
                        DotSeparator(diameter: 1.5)
                    }
                }
            }
        }
    }
}

// MARK: - 프리뷰
struct TagCloudView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeTagCloudView(
            tags: [
                .init(id: 1, name: "샐safdfasfdjsklfjsfk;slafjal러드"),
                .init(id: 2, name: "비fksdfjl;sajfkls;fjklsafdkl;fklsf;l건"),
                .init(id: 3, name: "매운맛"),
                .init(id: 4, name: "한식"),
                .init(id: 5, name: "초간단"),
                .init(id: 6, name: "홈파티"),
                .init(id: 7, name: "면요리"),
                .init(id: 8, name: "도시락")
            ]
        )
        .previewLayout(.sizeThatFits)
    }
}
