//
//  EatzDateTimeFormatters.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 11/27/25.
//

import Foundation

/// 앱 전역에서 사용하는 날짜 및 시간 데이터를 특정 포맷을 따르는 문자열로 변환하는 포맷터 모음입니다.
/// 날짜 및 시간 표시 규격을 통일하기 위해 사용하며, 포맷터는 메모리 효율을 위해 `static`으로 정의한 타입 프로퍼티를 사용합니다.
enum EatzDateTimeFormatters {
    // MARK: - 포맷터 모음
    
    /// "yyyy-MM-dd'T'HH:mm:ss" 형태로 포맷팅합니다.
    /// Spring Boot 서버 통신 시 ISO-8601에 대응하는 포맷입니다.
    static let iso8601 = create(dateFormat: "yyyy-MM-dd'T'HH:mm:ss")
    
    /// "2025년 1월 1일" 형태로 포맷팅합니다.
    static let yearMonthDayWithUnit = create(dateFormat: "yyyy년 M월 d일")
    
    /// "2025년" 형태로 포맷팅합니다.
    static let yearWithUnit = create(dateFormat: "yyyy년")
    
    /// "1월" 형태로 포맷팅합니다.
    static let monthWithUnit = create(dateFormat: "M월")
    
    /// "1월 1일" 형태로 포맷팅합니다.
    static let monthDayWithUnit = create(dateFormat: "M월 d일")
    
    /// 표준 날짜 포맷 "2026-03-20" 형태로 포맷팅합니다.
    static let standard = create(dateFormat: "yyyy-MM-dd")
    
    /// 날짜 구성의 '년', '월', '일', '요일'에서 '요일'만 "월" 형태로 포맷팅합니다.
    static let weekday = create(dateFormat: "E")
    
    /// 날짜 구성의 '년', '월', '일', '요일'에서 '일'만 "1" 형태로 포맷팅합니다.
    static let day = create(dateFormat: "d")
    
    /// "3일 전"과 같이 현재 시점을 기준으로 상대적인 표현으로 포맷팅합니다.
    static let relativeDateTime = createRelative()
    
    // MARK: - 달력, 날짜 관련 리소스
    
    static let calendar = Calendar.current
    
    /// 한 주를 구성하는 모든 요일을 `weekday` 포맷에 맞게 포맷팅된 문자열로 제공합니다.
    static var veryShortWeekdaySymbols: [String] {
        weekday.veryShortWeekdaySymbols ?? []
    }
    
    // MARK: - 포맷터 생성 메서드
    
    /// 포맷이 지정되지 않은 기본 포맷터를 만듭니다. 
    static func create() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = .current
        return formatter
    }
    
    /// 주어진 포맷을 따르는 문자열로 변환하는 포맷터를 만듭니다.
    private static func create(dateFormat: String) -> DateFormatter {
        let formatter = create()
        formatter.dateFormat = dateFormat
        return formatter
    }
    
    /// 현재를 기준으로 상대적 표현이 포함된 문자열로 변환하는 포맷터를 만듭니다.
    private static func createRelative() -> RelativeDateTimeFormatter {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateTimeStyle = .numeric
        return formatter
    }
}

extension Date {
    /// "2025년 1월 1일" 형태로 포맷팅된 문자열로 만듭니다.
    var formattedYearMonthDay: String {
        return EatzDateTimeFormatters.yearMonthDayWithUnit.string(from: self)
    }
    
    /// "1월" 형태로 포맷팅된 문자열로 만듭니다.
    var formattedMonth: String {
        return EatzDateTimeFormatters.monthWithUnit.string(from: self)
    }
    
    /// 날짜 구성의 '년', '월', '일', '요일'에서 '일'만 "1" 형태로 포맷팅된 문자열로 만듭니다.
    var formattedDay: String {
        return EatzDateTimeFormatters.day.string(from: self)
    }
    
    /// "1월 1일" 형태로 포맷팅된 문자열로 만듭니다.
    var formattedMonthDay: String {
        return EatzDateTimeFormatters.monthDayWithUnit.string(from: self)
    }

    /// 날짜 구성의 '년', '월', '일', '요일'에서 '요일'만 "월" 형태로 포맷팅된 문자열로 만듭니다.
    var formattedWeekday: String {
        return EatzDateTimeFormatters.weekday.string(from: self)
    }
    
    /// "2026-03-20" 형태로 포맷팅된 문자열로 만듭니다.
    var formattedStandard: String {
        return EatzDateTimeFormatters.standard.string(from: self)
    }
    
    /// "2025년" 형태로 포맷팅된 문자열로 만듭니다.
    var formattedYear: String {
        return EatzDateTimeFormatters.yearWithUnit.string(from: self)
    }
    
    /// 8일 이내면 "방금 전", "3일 전" 등 현재 시점 기준 상대적인 표현을,
    /// 그 이상이면 "yyyy년 M월 d일"인 형태로 포맷팅된 문자열로 만듭니다.
    var formattedRelative: String {
        let now = Date()
        let calendar = EatzDateTimeFormatters.calendar
        let components = calendar.dateComponents([.day], from: self, to: now)
        
        if let day = components.day, day < 8 {
            return EatzDateTimeFormatters.relativeDateTime.localizedString(for: self, relativeTo: now)
        } else {
            return self.formattedYearMonthDay
        }
    }
}
