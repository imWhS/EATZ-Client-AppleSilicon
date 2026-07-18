//
//  TokenUtils.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 3/24/26.
//

import Foundation

enum TokenUtils {
    /// Authorization 헤더에서 액세스 토큰을 추출합니다.
    static func extractAccessToken(from headers: [AnyHashable: Any]) -> String? {
        guard let header = headers["Authorization"] as? String else { return nil }
        let parts = header.split(separator: " ")
        guard parts.count == 2, parts[0] == "Bearer" else { return nil }
        return String(parts[1])
    }
    
    /// HttpOnly 쿠키에서 리프레시 토큰을 추출합니다.
    static func extractRefreshToken(from url: URL) -> String? {
        guard let cookies = HTTPCookieStorage.shared.cookies(for: url) else { return nil }
        return cookies
            .first(where: { $0.name == "RefreshToken" })?
            .value
    }
}
