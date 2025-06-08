//
//  Border.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 5/30/25.
//

import SwiftUI

struct Border: ViewModifier {
  var color: Color = .gray.opacity(0.3)
  var width: CGFloat = 1
  var radius: CGFloat = 24
  func body(content: Content) -> some View {
    content
      .overlay(
        RoundedRectangle(cornerRadius: radius)
          .stroke(color, lineWidth: width)
      )
      .cornerRadius(radius)
  }
}
extension View {
  func border(
    color: Color = .gray.opacity(0.3),
    width: CGFloat = 1,
    radius: CGFloat = 24
  ) -> some View {
    modifier(Border(color: color, width: width, radius: radius))
  }
}
