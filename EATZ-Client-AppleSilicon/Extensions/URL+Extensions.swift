//
//  URL+Extensions.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 7/6/26.
//

import Foundation

extension URL {
    /// 서버에서 내려주는 이미지 경로를 조합하여 완전한 URL로 만듭니다.
    /// - Parameter imagePath: 예) "/uploads/images/users/profiles/uuid.jpeg"
    init?(imageUrlString: String?) {
        guard let url = imageUrlString, !url.isEmpty else { return nil }
        
        // 카카오/구글 프로필 등 이미 완벽한 외부 HTTP 주소일 경우 그대로 사용
        if url.hasPrefix("http") {
            self.init(string: url)
        } else {
            let path = url.hasPrefix("/") ? url : "/\(url)"
            self.init(string: AppConfig.servingImageBaseUrl + path)
        }
    }
}
