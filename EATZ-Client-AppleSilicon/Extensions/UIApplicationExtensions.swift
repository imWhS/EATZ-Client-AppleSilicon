//
//  UIApplication.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 7/3/25.
//

import Foundation
import UIKit

extension UIApplication {
    func topViewController() -> UIViewController? {
        // 활성화된 씬들 중에서 keyWindow를 찾습니다.
        let keyWindow = connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter { $0.activationState == .foregroundActive }
            .first?.windows
            .filter { $0.isKeyWindow }
            .first
        
        var topController = keyWindow?.rootViewController
        while let presentedViewController = topController?.presentedViewController {
            topController = presentedViewController
        }
        return topController
    }
}
