//
//  NetworkError.swift
//  Eatz-AppleSilicon
//
//  Created by 손원희 on 5/9/25.
//

import Foundation
import Alamofire


/// 공통 에러 타입입니다.
///
/// 네트워크 및 서버에서 발생하는 통신 오류 정보를 가지는 `AFError` 또는
/// 서버가 HTTP 응답 바디 데이터로 보낸 `ErrorResponse`를 통합 관리, 사용할 수 있습니다.
enum NetworkError: Error {
    
    /// 네트워크 및 응답 데이터 파싱 오류.
    /// - Alamofire에 의해 생성된 오류임을 나타냅니다. 주로 네트워크, HTTP, 직렬화 오류가 해당합니다.
    case afError(AFError)
    
    /// 서버 내부 오류.
    /// - HTTP 응답 바디 데이터에 서버 내부의 상세 오류 정보를 포함함을 나타냅니다.
    case serverError(statusCode: Int, response: ErrorResponse?)
    
    /// 알 수 없는 오류.
    /// - 예기치 못한 상황에 의해 발생한 오류임을 나타냅니다. 올바르지 않은 요청 URL일 수도 있습니다.
    case unknown(_ message: String? = nil)
    
    /// HTTP 상태 코드.
    var statusCode: Int? {
        switch self {
        case .afError(let aFError): return aFError.responseCode
        case .serverError(let statusCode, _): return statusCode
        case .unknown: return nil
        }
    }
    
    /// 서버 오류 코드.
    /// - 서버 오류일 경우에만 제공됩니다.
    var errorCode: String? {
        if case .serverError(_, let response) = self {
            return response?.code
        } else {
            return nil
        }
    }
    
    /// 토큰 만료 여부.
    /// - 토큰 만료로 인한 오류가 아닌지 확인합니다.
    var isTokenExpiredError: Bool {
        if let code = self.errorCode {
            // 세션 만료를 의미하는 서버의 오류 코드 목록
            let sessionErrorCodes = [
                "TOKEN_ACCESS_EXPIRED",
                "TOKEN_ACCESS_INVALID",
                "TOKEN_REFRESH_EXPIRED",
                "TOKEN_REFRESH_MISSING"
            ]
            
            // 현재 에러 코드가 목록에 포함되어 있는지 확인하여 반환합니다.
            return sessionErrorCodes.contains(code)
        } else {
            // 서버가 오류 코드를 포함한 오류 정보를 없이 HTTP 상태 코드만 401(Unauthorized)로 보낸 경우, 클라이언트 측에선 세션(토큰) 문제로 간주합니다.
            if let statusCode = self.statusCode, statusCode == 401 {
                return true
            }
        }
        
        return false
    }
    
    
    /// 404(Not Found) 상태 코드 여부.
    /// - 요청한 데이터가 존재하지 않는지 확인합니다.
    var isNotFoundError: Bool {
        return self.statusCode == 404
    }
    
    /// 네트워크 또는 서버 측 문제로 인한 서비스 불가 여부.
    var isServiceUnavailable: Bool {
        if let statusCode = statusCode, (500...599).contains(statusCode) {
            return true
        }
        
        if case .afError(let afError) = self,
           let urlError = afError.underlyingError as? URLError {
            switch urlError.code {
            case .notConnectedToInternet,
                    .cannotConnectToHost,
                    .cannotFindHost,
                    .timedOut,
                    .dnsLookupFailed,
                    .networkConnectionLost:
                return true
            default: return false
            }
        }
        
        return false
    }
    
    /// 사용자 안내 메시지.
    var userMessage: String {
        switch self {
        case .afError(let afError):
            if let urlError = afError.underlyingError as? URLError {
                switch urlError.code {
                case .notConnectedToInternet:
                    return "인터넷에 연결되어 있지 않아요."
                case .networkConnectionLost:
                    return "네트워크 연결이 끊어졌어요."
                case .timedOut:
                    return "서버의 응답이 지연되고 있어서, 연결을 끊었어요."
                case .cannotFindHost, .cannotConnectToHost, .dnsLookupFailed:
                    return "서버에 연결할 수 없어요."
                case .badServerResponse, .resourceUnavailable:
                    return "해당 요청을 이용할 수 없어요."
                case .secureConnectionFailed:
                    return "서버와의 보안 연결에 실패했어요. 잠시 후 다시 시도해주세요."
                case .cannotLoadFromNetwork:
                    return "네트워크에서 데이터를 불러올 수 없어요."
                default:
                    break
                }
            }
            print("[NetworkError] afError | \(afError.localizedDescription)")
            return "알 수 없는 네트워크 오류가 발생했어요. 다시 시도해보시겠어요?"
        case .serverError(_, let errorResponse):
            return errorResponse?.message ?? "서버에서 문제가 발생했어요."
        case .unknown(let message):
            return message ?? "알 수 없는 오류가 발생했어요."
        }
    }
}
