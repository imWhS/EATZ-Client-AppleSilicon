//
//  AuthInterceptor.swift
//
//  Created by 손원희 on 5/15/25.
//

import Foundation
import Alamofire

final class AuthInterceptor: RequestInterceptor, @unchecked Sendable {
    private let tokenManager = TokenManager.shared
    private let authService = AuthService.shared
    private let authManager = AuthManager.shared
    
    private let MAX_RETRY_COUNT = 1
    
    private let lock = NSLock()
    private var isReissuing = false
    
    /// 액세스 토큰 만료로 인해 실패해서, 토큰 재발급 후 재실행을 기다리고 있는 요청 실행 클로저들을 보관합니다.
    private var requestsToRetry: [ (RetryResult) -> Void ] = []
    
    /// HTTP 요청 전처리를 담당합니다.
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, any Error>) -> Void) {
        var urlRequest = urlRequest
        
        // 액세스 토큰이 있다면, Authorization 헤더에 추가합니다.
        if let accessToken = tokenManager.loadAccessToken() {
            urlRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        
        completion(.success(urlRequest))
    }
    
    /// HTTP 요청에 대해 서버로부터 실패/오류 응답을 받은 경우의 처리를 담당합니다.
    func retry(_ request: Request, for session: Session, dueTo error: any Error, completion: @escaping (RetryResult) -> Void) {
        
        let method = request.request?.httpMethod ?? ""
        let path = request.request?.url?.path ?? ""
        
        /// 인증 오류 응답을 받은 요청이 아닌 경우, 재시도하지 않고 종료합니다.
        guard let response = request.response, response.statusCode == 401 else {
            completion(.doNotRetry)
            return
        }
                
        /// 토큰 재발급을 실패한 요청인 경우, 재시도하지 않고 종료합니다.
        if let url = request.request?.url?.absoluteString, url.contains("/reissue-token") {
            print("[AuthInterceptor.retry] \(method) \(path) | 토큰 재발급 요청이에요. 요청을 종료할게요.")
            completion(.doNotRetry)
            return
        }
        
        /// 이미 한 번 재시도한 적 있는 요청인 경우, 추가 시도하지 않고 종료합니다.
        if 0 < request.retryCount {
            print("[AuthInterceptor.retry] \(method) \(path) | 인증 재시도 최대 횟수에 도달한 요청이에요. 요청을 종료할게요.")
            completion(.doNotRetry)
            return
        }
        
        /// 액세스 토큰 만료로 인해 실패한 요청의 실행 클로저를 보관하고, 토큰 재발급 상태를 설정하는 것과 토큰 재발급 요청을 보내는 작업을 atomic 하게 처리하기 위해 lock을 설정합니다.
        lock.lock();
        defer {
            lock.unlock()
        }
        
        /// 액세스 토큰 만료로 인해 실패했던 요청 실행 클로저를 미리 보관해둡니다. 토큰 재발급 성공 후 재시도할 때 호출됩니다.
        requestsToRetry.append(completion)
        
        /// 이전에 발생한 다른 요청에 의해 이미 토큰 재발급 절차를 실행 중인 경우, 재시도하지 않고 종료합니다.
        if isReissuing {
            print("[AuthInterceptor.retry] \(method) \(path) | 이미 토큰 재발급 요청을 처리하고 있어서, 요청을 대기열에 추가한 상태로 종료할게요. | 현재 대기열의 요청 수: \(requestsToRetry.count)")
            return
        }
        
        /// 토큰 재발급 절차를 실행합니다.
        print("[AuthInterceptor.retry] \(method) \(path) | 토큰 재발급을 요청할게요. | 현재 대기열의 요청 수: \(requestsToRetry.count)")
        isReissuing = true
        
        /// 서버에 토큰 재발급 요청을 보냅니다.
        authService.reissueTokens { [weak self] result in
            guard let self = self else { return }
            
            /// 토큰 재발급 완료 시, 그 동안
            self.lock.lock()
            let requestsToProcess = self.requestsToRetry
            self.requestsToRetry.removeAll()
            self.lock.unlock()

            switch result {
            case .success:
                /// 토큰 재발급 성공: 해당 시점에 액세스 토큰이 만료되어 실패한 모든 요청 클로저들을 재시도 처리합니다.
                print("[AuthInterceptor.retry] \(method) \(path) | 토큰 재발급을 성공했어요! 대기열의 요청 \(requestsToProcess.count)개를 재시도 처리할게요.")
                requestsToProcess.forEach { $0(.retry) }
                
            case .failure(let error):
                /// 토큰 재발급 실패: 서버에서 해당 사용자의 세션을 만료시켰기 때문에, 해당 상황에 대응하는 로직을 실행합니다.
                print("[AuthInterceptor.retry] \(method) \(path) | 토큰 재발급 실패. AuthManager에게 세션 만료 처리를 위임할게요. | 현재 대기열의 요청 수: \(requestsToProcess.count)")
                
                /// 세션 만료로 인한 재로그인을 성공했을 때 재시도해야 할 모든 요청 클로저 실행 클로저를 미리 만들어둡니다.
                let retryAction: () -> Void = {
                    print("[AuthInterceptor] 재로그인 성공. 대기열의 \(requestsToProcess.count)개의 모든 요청을 재시도합니다.")
                    requestsToProcess.forEach { $0(.retry) }
                }
                
                self.authManager.sessionExpired(retryAction: retryAction)
            }

            self.lock.lock()
            self.isReissuing = false
            self.lock.unlock()
        }
    }
}
