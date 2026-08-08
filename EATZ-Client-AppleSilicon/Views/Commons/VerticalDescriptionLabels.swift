//
//  VerticalDescriptionLabels.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 8/8/26.
//

import SwiftUI

struct VerticalDescriptionLabels: View {
    let titleLabel: String
    let subtitleLabel: String
    
    init(_ titleLabel: String, _ subtitleLabel: String) {
        self.titleLabel = titleLabel
        self.subtitleLabel = subtitleLabel
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(titleLabel)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.black)
            Text(subtitleLabel)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.gray35)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
