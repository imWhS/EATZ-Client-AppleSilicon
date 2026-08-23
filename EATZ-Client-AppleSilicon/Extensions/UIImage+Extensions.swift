//
//  UIImage+Extensions.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 7/5/26.
//

import SwiftUI

extension UIImage {
    /// 이미지의 `가로/세로` 비율을 유지하면서, 가장 긴 변의 길이를 제한하여 사이즈를 변경합니다.
    func resized(maxDimension: CGFloat) -> UIImage? {
        let width = self.size.width
        let height = self.size.height
        let aspectRatio = width / height // 4/2, 2/4, 1/1
        
        var size: CGSize
        
        if width > height {
            // 이미지의 가로 길이가 가장 긴 변인 경우: maxDimension을 가로 길이로 새로 설정하고,
            // 세로 길이를 새로 설정된 가로 길이에 맞는 비율의 maxDimension / aspectRatio로 설정합니다.
            guard maxDimension < width else { return self }
            size = CGSize(width: maxDimension, height: maxDimension / aspectRatio)
        } else {
            // 이미지의 세로 길이가 가장 긴 변인 경우: maxDimension을 세로 길이로 새로 설정하고,
            // 가로 길이를 새로 설정된 세로 길이에 맞는 비율의 maxDimension * aspectRatio로 설정합니다.
            guard maxDimension < height else { return self }
            size = CGSize(width: maxDimension * aspectRatio, height: maxDimension)
        }
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0
        
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
