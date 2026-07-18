//
//  EatzDateDecodingStrategy.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 3/16/26.
//

import Foundation

/// 외부의 다양한 날짜, 시간 데이터를 디코딩하기 위한 전략 모음입니다.
enum EatzDateDecodingStrategy {
    /// Spring Boot의 LocalDateTime 타입을 지원합니다.
    static let springBootLocalDateTimeJson: JSONDecoder.DateDecodingStrategy = JSONDecoder.DateDecodingStrategy.custom { decoder in
        // 디코드 중인 JSON 데이터에서 날짜, 시간 값만 따로 꺼내와 String 문자열로 디코드합니다.
        let container = try decoder.singleValueContainer()
        let dateString = try container.decode(String.self)
        
        // LocalDateTime에서 ISO-8601로 변환 시 포함되는 가변 소수점 자릿수를 모두 대응할 수 있는 포맷터를 만듭니다.
        let formatter = EatzDateTimeFormatters.create()
        let formats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSS", // 소수점 자릿수가 6자리인 경우
            "yyyy-MM-dd'T'HH:mm:ss.SSS", // 소수점 자릿수가 3자리인 경우
            "yyyy-MM-dd'T'HH:mm:ss" // 소수점이 없는 경우
        ]
        
        // 가변 소수점 자릿수에 대응하는 포맷을 하나 씩 포맷터에 설정해서, 포맷터로 파싱을 시도해봅니다.
        for format in formats {
            formatter.dateFormat = format
            if let date = formatter.date(from: dateString) {
                return date
            }
        }
        
        // 모든 파싱 시도가 실패하면, 디코딩 실패 에러를 던집니다.
        throw DecodingError.dataCorruptedError(
            in: container,
            debugDescription: "날짜, 시간을 디코딩하지 못했어요. 알 수 없는 형식인 것 같아요: \(dateString)")
    }
}
