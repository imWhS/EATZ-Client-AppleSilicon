//
//  Encodable+Extensions.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 7/30/25.
//

import Foundation

extension Encodable {
    /// Encodable 객체를 `[String: Any]` Dictionary 타입으로 변환합니다.
    func toDictionary() -> [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed))
            .flatMap { $0 as? [String: Any] }
    }
}
