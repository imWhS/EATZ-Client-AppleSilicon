//
//  DismissAwareHostingController.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 7/4/25.
//

import SwiftUI
import UIKit

// Content는 모든 SwiftUI 뷰가 될 수 있다는 의미
class DismissAwareHostingController<Content: View>: UIHostingController<Content> {
    
    // 이 컨트롤러가 닫힐 때 실행될 클로저
    var onDismiss: (() -> Void)?
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // 뷰가 사라지면 onDismiss 클로저를 실행
        onDismiss?()
    }
}
