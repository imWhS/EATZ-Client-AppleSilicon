//
//  String+Extensions.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 3/24/26.
//

import Foundation

extension String {
    /// 지정된 길이 `limit`보다 긴 경우, 지정된 길이만큼 자르고 꼬리 문자열 `tail`을 붙입니다.
    func truncated(limit: Int = 16, tail: String = "...") -> String {
        if limit < self.count {
            return "\(self.prefix(limit))\(tail)"
        } else {
            return self
        }
    }
    
    /// 올바른 이메일 형식인지 확인합니다.
    var isValidEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegEx).evaluate(with: self)
    }
}
