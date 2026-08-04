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
    
    /// 올바른 형식의 이메일 주소인지 확인합니다.
    var isValidEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegEx).evaluate(with: self)
    }
    
    /// 올바른 형식의 HTTP(HTTPS) 웹 URL인지 확인합니다.
    var isValidURL: Bool {
        // 공백을 제거한 문자열이 비어있으면 유효하지 않음
        let trimmedString = self.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedString.isEmpty {
            return false
        }
        
        guard let url = URL(string: trimmedString),
              let scheme = url.scheme?.lowercased(),
              let host = url.host else { return false }
    
        return ["http", "https"].contains(scheme) && !host.isEmpty
    }
}
