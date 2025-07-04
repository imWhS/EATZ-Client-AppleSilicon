//
//  NetworkClient.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 5/15/25.
//

import Foundation
import Alamofire

/**
 NetworkClient는 통신 계층을 담당합니다.
 */
class NetworkClient {
    
    static let shared = NetworkClient()
    
    /**
     인증 인터셉터를 거치지 않는 세션입니다.
     주로 로그인, 토큰 재발급과 같이 액세스 토큰이 포함되지 않아야 하는 API 요청에 사용합니다.
     */
    private let basicSession: Session
    
    /**
     인증 인터셉터를 거치는 세션입니다.
     */
    private let authSession: Session
    
    private let baseUrl = "http://localhost:8080"
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.httpCookieAcceptPolicy = .always // 쿠키 허용
        configuration.httpShouldSetCookies = true // 쿠키 자동 설정
        configuration.httpCookieStorage = .shared // 공유 쿠키 저장소 사용
        
        basicSession = Session(configuration: configuration)
        authSession = Session(configuration: configuration, interceptor: AuthInterceptor())
    }
    
    /// Authorization 헤더에서 액세스 토큰을 추출합니다.
    private func extractAccessToken(from headers: [AnyHashable: Any]) -> String? {
      guard let header = headers["Authorization"] as? String else { return nil }
      let parts = header.split(separator: " ")
      guard parts.count == 2, parts[0] == "Bearer" else { return nil }
      return String(parts[1])
    }

    /// HttpOnly 쿠키에서 리프레시 토큰을 추출합니다.
    private func extractRefreshToken(from url: URL) -> String? {
      guard let cookies = HTTPCookieStorage.shared.cookies(for: url) else { return nil }
      return cookies
        .first(where: { $0.name == "RefreshToken" })?
        .value
    }
    
    private func decodeAPIError(from data: Data) -> ErrorResponse? {
        return try? JSONDecoder().decode(ErrorResponse.self, from: data)
    }
    
    public func request<T: Decodable>(
        endpointUrl: String,
        method: HTTPMethod,
        parameters: Parameters? = nil,
        decoder: JSONDecoder = JSONDecoder(),
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        guard let url = URL(string: baseUrl + endpointUrl) else {
            print("[NetworkClient.request] '\(baseUrl + endpointUrl)'은 유효하지 않은 URL이에요")
            completion(.failure(.unknown("유효하지 않은 URL이에요.")))
            return
        }
        
        print("[NetworkClient.request] \(method.rawValue) \(url.relativePath)")
        
        authSession.request(
            url,
            method: method,
            parameters: parameters,
            encoding: method == .get ? URLEncoding.default : JSONEncoding.default)
        .validate(statusCode: 200 ..< 300)
        .responseDecodable(of: T.self, decoder: decoder) { response in
            switch response.result {
            case .success(let decodable):
                completion(.success(decodable))
            case .failure(let afError):
                // 서버의 오류 데이터부터 확인합니다.
                if let data = response.data,
                   let apiError = self.decodeAPIError(from: data) {
                    // 서버의 오류 데이터가 HTTP 응답 바디에 존재하는 경우, 서버의 오류 데이터 속 메시지를 반환합니다.
                    print("[NetworkClient.request] \(method.rawValue) \(url.relativePath) | 서버 오류예요: \(apiError.message)")
                    let error = NetworkError.serverError(apiError)
                    completion(.failure(error))
                } else {
                    // 서버의 오류 데이터가 없는 경우, 네트워크 오류로 처리합니다.
                    print("[NetworkClient.request] \(method.rawValue) \(url.relativePath) | 네트워크 통신 오류예요: \(afError.localizedDescription)")
                    let error = NetworkError.afError(afError)
                    ErrorManager.shared.showError(message: error.userMessage)
                    completion(.failure(error))
                }
            }
            
        }
    }
    
    public func requestOptional<T: Decodable>(
        endpointUrl: String,
        method: HTTPMethod,
        parameters: Parameters? = nil,
        decoder: JSONDecoder = JSONDecoder(),
        completion: @escaping (Result<T?, NetworkError>) -> Void
    ) {
        guard let url = URL(string: baseUrl + endpointUrl) else {
            print("[NetworkClient.requestOptional] '\(baseUrl + endpointUrl)'은 유효하지 않은 URL이에요")
            completion(.failure(.unknown("유효하지 않은 URL이에요.")))
            return
        }
        
        print("[NetworkClient.requestOptional] \(method.rawValue) \(url.relativePath)")
        authSession.request(
            url,
            method: method,
            parameters: parameters,
            encoding: method == .get ? URLEncoding.default : JSONEncoding.default)
        .validate(statusCode: 200 ..< 300)
        .responseData { response in
            switch response.result {
            case .success(let data):
                guard let httpResponse = response.response else {
                    print("[NetworkClient.requestOptional] \(method.rawValue) \(url.relativePath) | HTTP 응답 데이터가 없어요.")
                    completion(.failure(.unknown("서버로부터 HTTP 응답 데이터를 받지 못했어요.")))
                    return
                }
                
                let status = httpResponse.statusCode
                if status == 204 {
                    print("[NetworkClient.requestOptional] \(method.rawValue) \(url.relativePath) | 204 No Content → nil 반환")
                    completion(.success(nil))
                } else if (200..<300).contains(status) {
                    do {
                        let decoded = try decoder.decode(T.self, from: data)
                        print("[NetworkClient.requestOptional] \(method.rawValue) \(url.relativePath) | 서버 응답 디코딩 성공")
                        completion(.success(decoded))
                    } catch {
                        print("[NetworkClient.requestOptional] \(method.rawValue) \(url.relativePath) | 디코딩 오류: \(error.localizedDescription)")
                        completion(.failure(.unknown("응답 데이터 처리를 실패했어요.")))
                    }
                // 204, 200~299에 해당하지 않는 상태 코드가 온 경우
                } else {
                    print("[NetworkClient.requestOptional] \(method.rawValue) \(url.relativePath) | API 처리 오류 - 응답 코드: \(status)")
                    completion(.failure(.unknown("서버에서 요청 처리를 실패했어요: \(status)")))
                }
            case .failure(let afError):
                // 서버의 오류 데이터부터 확인합니다.
                if let data = response.data,
                   let apiError = self.decodeAPIError(from: data) {
                    // 서버의 오류 데이터가 HTTP 응답 바디에 존재하는 경우, 서버의 오류 데이터 속 메시지를 반환합니다.
                    print("[NetworkClient.requestOptional] \(method.rawValue) \(url.relativePath) | 서버 오류예요: \(apiError.message)")
                    let error = NetworkError.serverError(apiError)
                    completion(.failure(error))
                } else {
                    // 서버의 오류 데이터가 없는 경우, 네트워크 오류로 처리합니다.
                    print("[NetworkClient.requestOptional] \(method.rawValue) \(url.relativePath) | 네트워크 통신 오류예요: \(afError.localizedDescription)")
                    let error = NetworkError.afError(afError)
                    ErrorManager.shared.showError(message: error.userMessage)
                    completion(.failure(error))
                }
            }
        }
    }
    
    public func authRequest(
        endpointUrl: String,
        method: HTTPMethod = .post,
        parameters: Parameters? = nil,
        completion: @escaping (Result<AuthTokens, NetworkError>) -> Void
    ) {
        guard let url = URL(string: baseUrl + endpointUrl) else {
            print("[NetworkClient.authRequest] '\(baseUrl + endpointUrl)'은 유효하지 않은 URL이에요")
            completion(.failure(.unknown("유효하지 않은 URL이에요.")))
            return
        }
        
        print("[NetworkClient.authRequest] \(method.rawValue) \(url.relativePath)")
        
        basicSession.request(
            url,
            method: method,
            parameters: parameters,
            encoding: JSONEncoding.default)
        .validate(statusCode: 200 ..< 300)
        .response { response in
            // 서버의 HTTP 응답을 확인합니다.
            guard let httpResponse = response.response else {
                print("[NetworkClient.authRequest] \(method.rawValue) \(url.relativePath) | 서버로부터 받은 응답이 없어요.")
                completion(.failure(.afError(AFError.responseValidationFailed(reason: .dataFileNil))))
                return
            }
            
            // 서버의 오류 응답을 확인합니다.
            let statusCode = httpResponse.statusCode
            
            // 서버가 오류 응답과 함께 오류 정보 데이터를 바디에 포함시켰는지 확인합니다.
            if !(200 ..< 300).contains(statusCode) {
                if let data = response.data, let apiError = self.decodeAPIError(from: data) {
                    print("[NetworkClient.authRequest] \(method.rawValue) \(url.relativePath) | 서버 오류예요(\(statusCode)) | \(apiError.errorCode) | \(apiError.message)")
                    completion(.failure(.serverError(apiError)))
                } else {
                    print("[NetworkClient.authRequest] \(method.rawValue) \(url.relativePath) | 알 수 없는 서버 오류예요(\(statusCode)) | 서버가 오류 정보를 제공하지 않았어요.")
                    completion(.failure(.unknown("알 수 없는 서버 오류가 발생했어요.")))
                }
                return
            }
            
            // 네트워크 오류 여부를 확인합니다.
            if let afError = response.error {
                print("[NetworkClient.authRequest] \(method.rawValue) \(url.relativePath) | 네트워크 통신 오류예요 | \(afError.localizedDescription)")
                let error = NetworkError.afError(afError)
//                ErrorManager.shared.showError(message: error.userMessage)
                completion(.failure(error))
                return
            }
            
            // Authorizatin 헤더에서 액세스 토큰을 추출합니다.
            guard let accessToken = self.extractAccessToken(from: response.response!.allHeaderFields) else {
                print("[NetworkClient.authRequest] \(method.rawValue) \(url.relativePath) | Authorization 헤더를 파싱하지 못해서, 액세스 토큰을 추출하지 못했어요.")
                completion(.failure(.unknown("서버로부터 올바른 액세스 토큰을 받지 못했어요.")))
                return
            }
            
            // HttpOnly 쿠키에서 리프레시 토큰을 추출합니다.
            guard let cookies = HTTPCookieStorage.shared.cookies(for: url) else {
                print("[NetworkClient.authRequest] \(method.rawValue) \(url.relativePath) | HttpOnly 쿠키가 존재하지 않아요.")
                completion(.failure(.afError(AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: httpResponse.statusCode)))))
                return
            }
            
            guard let refreshToken = self.extractRefreshToken(from: url) else {
                print("[NetworkClient.authRequest]\(method.rawValue) \(url.relativePath) | HttpOnly 쿠키에서 리프레시 토큰을 추출하지 못했어요.")
                completion(.failure(.unknown("서버로부터 올바른 리프레시 토큰을 받지 못했어요.")))
                return
            }
            
            completion(.success(AuthTokens(accessToken: accessToken, refreshToken: refreshToken)))
        }
    }

}
