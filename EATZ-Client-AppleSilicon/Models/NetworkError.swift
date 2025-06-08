//
//  NetworkError.swift
//  Eatz-AppleSilicon
//
//  Created by 손원희 on 5/9/25.
//

import Foundation
import Alamofire

/**
 네트워크 및 서버의 HTTP 오류를 다루는 AFError와 서버가 HTTP 응답 바디 데이터로 제공하는 오류 정보(서버의 오류 정보)를 포함하는 ErrorResponse를 묶은 오류 타입입니다.
 */
enum NetworkError: Error {
    
//    case invalidUrl
    
    // Alamofire에 의해 생성된 오류임을 나타냅니다. 주로 네트워크, HTTP, 직렬화 오류가 해당합니다.
    case afError(AFError)
    
    // HTTP 응답 바디 데이터에 서버의 상세 오류 정보를 포함함을 나타냅니다.
    case serverError(ErrorResponse)
    
    // 그 외 예기치 못한 상황에 의해 발생한 오류임을 나타냅니다.
    case unknown(_ message: String? = "알 수 없는 네트워크 오류예요")
    
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
            
            return "알 수 없는 네트워크 오류가 발생했어요. 다시 시도해보시겠어요?"
        case .serverError(let errorResponse):
            return errorResponse.message
        case .unknown:
            return "알 수 없는 오류가 발생했어요."
        }
    }
}
