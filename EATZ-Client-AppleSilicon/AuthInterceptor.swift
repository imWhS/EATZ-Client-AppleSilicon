//
//  AuthInterceptor.swift
//  AuthInterceptorSample
//
//  Created by 손원희 on 5/15/25.
//

import Foundation
import Alamofire

class AuthInterceptor: RequestInterceptor, @unchecked Sendable {
    
    private let authManager = AuthManager.shared
    
    private let MAX_RETRY_COUNT = 1
    
    private let lock = NSLock()
    
    private var isRefreshing = false
    
    private var requestsToRetry: [ (RetryResult) -> Void ] = []
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, any Error>) -> Void) {
        var request = urlRequest
        print("[AuthInterceptor.adapt] Hello!!")
        
        var isRefreshTokenExist: Bool = false
        if let url = URL(string: "http://localhost:8080"),
           let cookies = HTTPCookieStorage.shared.cookies(for: url) {
            for cookie in cookies where cookie.name == "RefreshToken" {
                
                isRefreshTokenExist = true
            }
        }
        
        if isRefreshTokenExist {
            print("[AuthInterceptor.adapt] HttpOnly 쿠키에 리프레시 토큰이 존재해요")
        } else {
            print("[AuthInterceptor.adapt] 리프레시 토큰이 없어요")
        }
        
        if let accessToken = KeychainService.load(key: "accessToken") {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            print("[AuthInterceptor.adapt] 액세스 토큰이 존재해요 | \(accessToken.suffix(8))")
        } else {
            print("[AuthInterceptor.adapt] 액세스 토큰이 없어요")
        }
        
        completion(.success(request))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: any Error, completion: @escaping (RetryResult) -> Void) {
        print("[AuthInterceptor.retry] Hello!!")
        
        print("[AuthInterceptor.retry] 락을 설정했어요.")
        lock.lock(); defer {
            lock.unlock()
            print("[AuthInterceptor.retry] 락을 해제했어요.")
        }
        
        print("[AuthInterceptor.retry] 대기 목록에 추가된 요청 수: \(requestsToRetry.count) | \(request.request?.url?.relativePath ?? "")")
        requestsToRetry.append(completion)
        guard !isRefreshing else {
            print("[AuthInterceptor.retry] 이미 다른 스레드가 토큰 재발급 API 요청 중이어서, 해당 요청을 대기 목록에 넣어두기만 했어요. | \(request.request?.url?.relativePath ?? "")")
            return
        }
        
        isRefreshing = true
        print("isRefreshing is true")
        print("[AuthInterceptor.retry] 토큰 재발급 API 요청을 시도할게요. | \(request.request?.url?.relativePath ?? "")")
        
        authManager.reissueTokens { result in
            self.isRefreshing = false
            print("[AuthInterceptor.retry] 토큰 재발급 API 요청이 끝났어요.")
            let retryResult: RetryResult = {
                switch result {
                case .success:
                    print("[AuthInterceptor.retry] 액세스 토큰 재발급을 성공했어요! 토큰 재발급 API 요청을 재시도할게요 | \(request.request?.url?.relativePath ?? "")")
                    return .retry
                case .expired:
                    print("[AuthInterceptor.retry] 리프레시 토큰이 유효하지 않아요. 토큰 재발급 API 요청을 종료할게요 | \(request.request?.url?.relativePath ?? "")")
                    return .doNotRetry
                case .networkError:
                    print("[AuthInterceptor.retry] 토큰 재발급 API 요청을 위한 네트워크 통신 중 오류가 발생했어요 | \(request.request?.url?.relativePath ?? "")")
                    return .retry
                }
            }()
            
            for (index, requestToRetry) in self.requestsToRetry.enumerated() {
                print("[AuthInterceptor.retry] requestsToRetry의 \(self.requestsToRetry.count)개 중 \(index + 1)번 요청 클로저를 \(retryResult) 파라미터로 호출할게요 | \(request.request?.url?.relativePath ?? "")")
                requestToRetry(retryResult)
            }
            
//            self.requestsToRetry.forEach {
//                print("[AuthInterceptor.retry] requestsToRetry의 [\(String(describing: $0)) / \(self.requestsToRetry.count)]번 요청을 재시도할게요 | \(request.request?.url?.relativePath ?? "")")
//                $0(retryResult) }
            
            self.requestsToRetry.removeAll()
        }
    }
    
}
