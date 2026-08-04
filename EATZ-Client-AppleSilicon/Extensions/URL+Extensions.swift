//
//  URL+Extensions.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 7/6/26.
//

import Foundation

extension URL {
    /// 서버 도메인을 포함하는, 요청 가능한 이미지 URL를 만듭니다.
    /// - Parameter imageUrlString: Ex. "/uploads/images/users/profiles/uuid.jpeg"
    init?(imageUrlString: String?) {
        guard let url = imageUrlString, !url.isEmpty else { return nil }
        
        if url.hasPrefix("http") {
            self.init(string: url)
        } else {
            let path = url.hasPrefix("/") ? url : "/\(url)"
            self.init(string: AppConfig.servingImageBaseUrl + path)
        }
    }
}
