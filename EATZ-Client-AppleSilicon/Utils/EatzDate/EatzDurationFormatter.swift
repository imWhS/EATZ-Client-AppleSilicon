//
//  EatzDurationFormatter.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 11/25/25.
//

import Foundation

/// '초'나 '분' 단위의 시간 간격 데이터를 "1시간 30분 15초"와 같은 한글 시간 간격 문자열로 변환합니다.
enum EatzDurationFormatter {
    /// '분' 단위를 한글 시간 간격 문자열로 변환합니다.
    static func minutes(from minutes: Int?) -> String? {
        guard let minutes = minutes, 0 < minutes else { return nil }
        let seconds = minutes * 60
        return formatter.string(from: TimeInterval(seconds))
    }
    
    /// '초' 단위를 한글 시간 간격 문자열로 변환합니다.
    static func seconds(from seconds: Int?) -> String? {
        guard let seconds = seconds, 0 < seconds else { return nil }
        return formatter.string(from: TimeInterval(seconds))
    }
    
    /// 여러 개의 '초' 단위를 한글 시간 간격 문자열로 변환합니다.
    static func totalSeconds(from totalSeconds: Int?...) -> String? {
        let sum = totalSeconds.compactMap { $0 }.reduce(0, +)
        return seconds(from: sum)
    }
    
    /// '초' 단위의 시간 간격 데이터를 한국 시간, 분, 초 단위로 구성된 문자열로 변환하는 포맷터입니다.
    private static let formatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .full
        formatter.zeroFormattingBehavior = .dropAll
        
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "ko_KR")
        formatter.calendar = calendar
        
        return formatter
    }()
}
