//
//  AuthInterceptor.swift
//  AuthInterceptorSample
//
//  Created by 손원희 on 5/15/25.
//

import Foundation
import Alamofire

class AuthInterceptor: RequestInterceptor, @unchecked Sendable {
    
    private let MAX_RETRY_COUNT = 1
    
    private let authManager = AuthManager.shared
    
    private let lock = NSLock()
    
    private var isRefreshing = false
    
    private var requestsToRetry: [ (RetryResult) -> Void ] = []
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, any Error>) -> Void) {
        var request = urlRequest
        
        if let accessToken = KeychainService.load(key: "accessToken") {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            print("[AuthInterceptor.adapt] 액세스 토큰을 HTTP 요청에 포함시킬게요. | \(accessToken.suffix(8)) | \(request.url?.relativePath ?? "")")
        } else {
            completion(.success(request))
            return
        }
        
        if let url = URL(string: "http://localhost:8080"),
           let cookies = HTTPCookieStorage.shared.cookies(for: url) {
            for cookie in cookies where cookie.name == "RefreshToken" {
                print("[AuthInterceptor.adapt] 리프레시 토큰이 HttpOnly 쿠키에 포함되어 있어요. | \(cookie.value.suffix(8)) | \(request.url?.relativePath ?? "")")
            }
        }
        
        completion(.success(request))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: any Error, completion: @escaping (RetryResult) -> Void) {
//        print("<AuthInterceptor.retry>")
        
        if request.retryCount >= MAX_RETRY_COUNT {
//            print("[AuthInterceptor.retry] 최대 재시도 수(총 \(MAX_RETRY_COUNT)번 중 \(request.retryCount + 1)번)를 초과해서, 해당 요청을 종료할게요. | \(request.request?.url?.relativePath ?? "")")
            completion(.doNotRetry)
            return
        }
        
        if !(authManager.isLoggedIn) {
            print("[AuthInterceptor.retry] 전역 비로그인 상태여서, 액세스 토큰 없이 해당 요청을 재시도할게요. | \(request.request?.url?.relativePath ?? "")")
            authManager.clearTokens()
            completion(.retry)
            return
        }
        
        
        lock.lock(); defer {
            lock.unlock()
        }
        
        if (!requestsToRetry.isEmpty) {
            print("[AuthInterceptor.retry] 대기 목록에 추가된 요청 수: \(requestsToRetry.count) | \(request.request?.url?.relativePath ?? "")")
        }

        requestsToRetry.append(completion)
        guard !isRefreshing else {
            print("[AuthInterceptor.retry] 이미 다른 스레드가 토큰 재발급 API 요청 중이어서, 해당 요청을 대기 목록에 넣어두기만 했어요. | \(request.request?.url?.relativePath ?? "")")
            return
        }
        
        isRefreshing = true
        authManager.reissueTokens { result in
            self.isRefreshing = false
            let retryResult: RetryResult = {
                switch result {
                case .success(()):
                    print("[AuthInterceptor.retry] 리프레시 토큰 재발급을 성공해서, 해당 요청을 재시도할게요. | \(request.request?.url?.relativePath ?? "")")
                    return .retry
                case .failure(let networkError):
                    switch networkError {
                    case .serverError(let errorResponse):
                        if errorResponse.errorCode == "TOKEN_REFRESH_EXPIRED"
                            || errorResponse.errorCode == "TOKEN_REFRESH_MISSING" {
                            print("[AuthInterceptor.retry] 리프레시 토큰이 만료되어서, 해당 요청을 종료할게요. | \(request.request?.url?.relativePath ?? "")")
                            return .doNotRetry
                        } else {
                            print("[AuthInterceptor.retry] 서버 오류가 발생했어요. 해당 요청을 종료할게요. | \(request.request?.url?.relativePath ?? "")")
                            return .doNotRetry
                        }
                    case .afError, .unknown:
                        // 네트워크/알 수 없는 에러는 1회 재시도 후 실패
                        if request.retryCount < self.MAX_RETRY_COUNT {
                            print("[AuthInterceptor.retry] 네트워크 오류가 발생했어요. 해당 요청을 재시도할게요. | \(request.request?.url?.relativePath ?? "")")
                            return .retry
                        } else {
                            print("[AuthInterceptor.retry] 네트워크 오류가 발생했어요. 최대 재시도 횟수(\(self.MAX_RETRY_COUNT)번 중 \(request.retryCount + 1)번)에 도달했기 떄문에 해당 요청을 종료할게요. | \(request.request?.url?.relativePath ?? "")")
                            return .doNotRetry
                        }
                    }
                }
            }()
            
            
            for (index, requestToRetry) in self.requestsToRetry.enumerated() {
                print("[AuthInterceptor.retry] requestsToRetry의 \(self.requestsToRetry.count)개 중 \(index + 1)번 요청 클로저를 \(retryResult) 파라미터로 호출할게요. | \(request.request?.url?.relativePath ?? "")")
                requestToRetry(retryResult)
            }

            self.requestsToRetry.removeAll()
        }
    }
    
}
