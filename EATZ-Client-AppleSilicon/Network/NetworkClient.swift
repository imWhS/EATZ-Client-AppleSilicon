//
//  NetworkClient.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 5/15/25.
//

import Foundation
import Alamofire

/// 서버와의 통신 계층을 담당합니다.
class NetworkClient {
    static let shared = NetworkClient()
    
    /// 인증 인터셉터를 거치지 않는 세션입니다.
    /// 주로 로그인, 토큰 재발급과 같이 액세스 토큰이 포함되지 않아야 하는 API 요청에 사용합니다.
    private let basicSession: Session
    
    /// 인증 인터셉터를 거치는 세션입니다.
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
    
    /// 요청 URL에 쿼리 파라미터로 날짜, 시간을 포함해야 할 때 사용하는 인코더입니다.
    /// `Date` 타입의 데이터를 ISO8601 포맷으로 변환됩니다.
    private static let customUrlParameterEncoder: URLEncodedFormParameterEncoder = {
        let encoder = URLEncodedFormEncoder(
            arrayEncoding: .noBrackets,
            dateEncoding: .formatted(EatzDateTimeFormatters.iso8601))
        return URLEncodedFormParameterEncoder(encoder: encoder, destination: .queryString)
    }()
    
    /// Spring Boot 서버로 요청을 보낼 때 사용할 수 있는 JSON 데이터 인코더입니다.
    private static let springBootLocalDateTimeJsonParameterEncoder: JSONParameterEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = EatzDateEncodingStrategy.springBootLocalDateTimeJson
        return JSONParameterEncoder(encoder: encoder)
    }()
    
    /// Spring Boot 서버가 응답으로 보낸 JSON 데이터에 사용할 수 있는 디코더입니다.
    private static let springBootLocalDateTimeJsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = EatzDateDecodingStrategy.springBootLocalDateTimeJson
        return decoder
    }()
    
    /// Alamofire의 오류 응답 바디 데이터를 공통 에러 타입인 `NetworkError`로 생성합니다.
    /// - 서버의 오류 응답 바디에 ErrorResponse 타입의 데이터가 있는 경우: `.serverError`로 생성
    /// - 서버의 오류 응답 바디 데이터가 없는 경우: AFError를 유지하며 `.afError`로 생성
    private func createNetworkError<T>(
        _ response: AFDataResponse<T>,
        _ error: AFError,
        _ statusCode: Int
    ) -> NetworkError {
        if let data = response.data,
           let apiError = try? Self.springBootLocalDateTimeJsonDecoder.decode(ErrorResponse.self, from: data) {
            return .serverError(statusCode: statusCode, response: apiError)
        } else {
            return .afError(error)
        }
    }
    
    private func getEncoder(method: HTTPMethod, type: EncodingType) -> ParameterEncoder {
        switch type {
        case .auto:
            return (method == .get || method == .delete)
                            ? Self.customUrlParameterEncoder
                            : Self.springBootLocalDateTimeJsonParameterEncoder
        case .json: return Self.springBootLocalDateTimeJsonParameterEncoder
        case .url: return Self.customUrlParameterEncoder
        }
    }
    
    /// 서버에 `multipart/form-data` 형식의 단일 이미지 업로드를 요청합니다.
    func uploadImage<D: Decodable>(
        endpointUrl: String,
        method: HTTPMethod = .post,
        imageData: Data,
        fileName: String = "image.jpeg",
        completion: @escaping (Result<D, NetworkError>) -> Void)
    {
        guard let url = URL(string: AppConfig.apiBaseUrl + endpointUrl) else {
            print("[NetworkClient] AUTH | '\(AppConfig.apiBaseUrl + endpointUrl)'은 유효하지 않은 URL이에요.")
            completion(.failure(.unknown("유효하지 않은 URL이에요.")))
            return
        }
        
        print("[NetworkClient] AUTH | PUT \(url.absoluteString) URL을 통한 이미지 업로드 요청 시도")
        authSession.upload(
            multipartFormData: {
                $0.append(
                    imageData,
                    withName: "image",
                    fileName: fileName,
                    mimeType: "image/jpeg")},
            to: url,
            method: method
        )
        .validate(statusCode: 200 ..< 300)
        .responseDecodable(of: D.self, decoder: Self.springBootLocalDateTimeJsonDecoder) { response in
            let statusCode = response.response?.statusCode ?? 0
            switch response.result {
            case .success(let response): completion(.success(response))
            case .failure(let error):
                print("[NetworkClient.uploadImage] \(method.rawValue) \(url.absoluteString) | 오류 발생: \(statusCode)")
                completion(.failure(self.createNetworkError(response, error, statusCode)))
            }
        }
    }
    
    public func requestOptional<D: Decodable>(
        endpointUrl: String,
        method: HTTPMethod,
        completion: @escaping (Result<D?, NetworkError>) -> Void)
    {
        self.requestOptional(
            endpointUrl: endpointUrl,
            method: method,
            parameters: nil as String?,
            completion: completion
        )
    }
    
    public func requestOptional<E: Encodable, D: Decodable>(
        endpointUrl: String,
        method: HTTPMethod,
        parameters: E? = nil,
        completion: @escaping (Result<D?, NetworkError>) -> Void)
    {
        guard let url = URL(string: AppConfig.apiBaseUrl + endpointUrl) else {
            print("[NetworkClient.requestOptional] '\(AppConfig.apiBaseUrl + endpointUrl)'은 유효하지 않은 URL이에요.")
            completion(.failure(.unknown("유효하지 않은 URL이에요.")))
            return
        }
        
        print("[NetworkClient.requestOptional] \(method.rawValue) \(url.absoluteString) 요청 시도")
        
        let encoder: ParameterEncoder = (method == .get) || (method == .delete)
        ? Self.customUrlParameterEncoder
        : Self.springBootLocalDateTimeJsonParameterEncoder
        
        authSession.request(
            url,
            method: method,
            parameters: parameters,
            encoder: encoder)
        .validate(statusCode: 200 ..< 300)
        .responseData { response in
            switch response.result {
            case .success(let data):
                guard let httpResponse = response.response else {
                    print("[NetworkClient.requestOptional] \(method.rawValue) \(url.relativePath) | HTTP 응답 데이터가 없어요.")
                    completion(.failure(.unknown("서버로부터 HTTP 응답 데이터를 받지 못했어요.")))
                    return
                }
                
                let statusCode = httpResponse.statusCode
                if statusCode == 204 {
                    print("[NetworkClient.requestOptional] \(method.rawValue) \(url.relativePath) | 204 No Content → nil 반환")
                    completion(.success(nil))
                    return
                }
                
                // HTTP 응답 코드가 200~299인 경우
                do {
                    let decoded = try Self.springBootLocalDateTimeJsonDecoder.decode(D.self, from: data)
                    print("[NetworkClient.requestOptional] \(method.rawValue) \(url.relativePath) | 서버 응답 디코딩 성공")
                    completion(.success(decoded))
                } catch {
                    print("[NetworkClient.requestOptional] \(method.rawValue) \(url.relativePath) | 디코딩 오류: \(error.localizedDescription)")
                    completion(.failure(.unknown("응답 데이터 처리를 실패했어요.")))
                }
            case .failure(let error):
                let statusCode = response.response?.statusCode ?? 0
                print("[NetworkClient.authRequest] \(method.rawValue) \(url.relativePath) | 서버 오류예요(\(statusCode))")
                completion(.failure(self.createNetworkError(response, error, statusCode)))
            }
        }
    }
    
    public func authRequest(
        endpointUrl: String,
        method: HTTPMethod = .post,
        completion: @escaping (Result<AuthTokens, NetworkError>) -> Void)
    {
        self.authRequest(
            endpointUrl: endpointUrl,
            method: method,
            parameters: nil as String?,
            completion: completion
        )
    }
    
    public func authRequest<E: Encodable>(
        endpointUrl: String,
        disableApiBaseUrl: Bool = false,
        method: HTTPMethod = .post,
        parameters: E? = nil,
        completion: @escaping (Result<AuthTokens, NetworkError>) -> Void)
    {
        guard let url = URL(string: (disableApiBaseUrl ? AppConfig.serverDomain : AppConfig.apiBaseUrl) + endpointUrl) else {
            print("[NetworkClient.authRequest] '\((disableApiBaseUrl ? AppConfig.serverDomain : AppConfig.apiBaseUrl) + endpointUrl)'은 유효하지 않은 URL이에요.")
            completion(.failure(.unknown("유효하지 않은 URL이에요.")))
            return
        }
        
        print("[NetworkClient.authRequest] \(method.rawValue) \(url.relativePath)")
            
        let encoder: ParameterEncoder = (method == .get) || (method == .delete)
            ? Self.customUrlParameterEncoder
            : Self.springBootLocalDateTimeJsonParameterEncoder
        
        basicSession.request(
            url,
            method: method,
            parameters: parameters,
            encoder: encoder)
        .validate(statusCode: 200 ..< 300)
        .response { response in
            let statusCode = response.response?.statusCode ?? 0
            
            switch response.result {
            case .success:
                guard let httpResponse = response.response else {
                    print("[NetworkClient.authRequest] \(method.rawValue) \(url.relativePath) | 서버로부터 받은 응답이 없어요.")
                    completion(.failure(.unknown("서버로부터 받은 응답이 없어요.")))
                    return
                }
                
                guard let accessToken = TokenUtils.extractAccessToken(from: httpResponse.allHeaderFields) else {
                    print("[NetworkClient.authRequest] \(method.rawValue) \(url.relativePath) | Authorization 헤더를 파싱하지 못해서, 액세스 토큰을 추출하지 못했어요.")
                    completion(.failure(.unknown("서버로부터 올바른 액세스 토큰을 받지 못했어요.")))
                    return
                }
                
                guard let refreshToken = TokenUtils.extractRefreshToken(from: url) else {
                    print("[NetworkClient.authRequest]\(method.rawValue) \(url.relativePath) | HttpOnly 쿠키에서 리프레시 토큰을 추출하지 못했어요.")
                    completion(.failure(.unknown("서버로부터 올바른 리프레시 토큰을 받지 못했어요.")))
                    return
                }
                
                completion(.success(AuthTokens(accessToken: accessToken, refreshToken: refreshToken)))
            case .failure(let error):
                print("[NetworkClient.authRequest] \(method.rawValue) \(url.relativePath) | 서버 오류예요(\(statusCode))")
                completion(.failure(self.createNetworkError(response, error, statusCode)))
            }
        }
    }
    
    public func request<D: Decodable>(
        endpointUrl: String,
        method: HTTPMethod,
        parameters: D? = nil,
        completion: @escaping (Result<D, NetworkError>) -> Void)
    {
        self.request(
            endpointUrl: endpointUrl,
            method: method,
            parameters: nil as String?,
            completion: completion
        )
    }
    
    public func request<E:Encodable, D: Decodable>(
        endpointUrl: String,
        method: HTTPMethod,
        parameters: E? = nil,
        encodingType: EncodingType = .auto,
        completion: @escaping (Result<D, NetworkError>) -> Void)
    {
        performDecodableRequest(
            session: authSession,
            endpointUrl: endpointUrl,
            method: method,
            parameters: parameters,
            encodingType: encodingType,
            completion: completion
        )
    }
    
    public func requestPublic<D: Decodable>(
        endpointUrl: String,
        method: HTTPMethod,
        completion: @escaping (Result<D, NetworkError>) -> Void)
    {
        requestPublic(
            endpointUrl: endpointUrl,
            method: method,
            parameters: nil as [String: String]?,
            completion: completion
        )
    }
    
    public func requestPublic<E:Encodable, D: Decodable>(
        endpointUrl: String,
        method: HTTPMethod,
        parameters: E? = nil,
        completion: @escaping (Result<D, NetworkError>) -> Void)
    {
        performDecodableRequest(
            session: basicSession,
            endpointUrl: endpointUrl,
            method: method,
            parameters: parameters,
            completion: completion
        )
    }

    public func requestPublicNoContent<E: Encodable>(
        endpointUrl: String,
        method: HTTPMethod,
        parameters: E? = nil,
        completion: @escaping (Result<Void, NetworkError>) -> Void)
    {
        guard let url = URL(string: AppConfig.apiBaseUrl + endpointUrl) else {
            print("[NetworkClient.requestPublicNoContent] '\(AppConfig.apiBaseUrl + endpointUrl)'은 유효하지 않은 URL이에요.")
            completion(.failure(.unknown("유효하지 않은 URL이에요.")))
            return
        }
        
        print("[NetworkClient.requestPublicNoContent] \(method.rawValue) \(url.absoluteString) 요청 시도")
        
        let encoder: ParameterEncoder = (method == .get) || (method == .delete)
            ? Self.customUrlParameterEncoder
            : Self.springBootLocalDateTimeJsonParameterEncoder
        
        basicSession.request(
            url,
            method: method,
            parameters: parameters,
            encoder: encoder)
        .validate(statusCode: 200 ..< 300)
        .response { response in
            let statusCode = response.response?.statusCode ?? 0
                        
            switch response.result {
            case .success(_): completion(.success(()))
            case .failure(let error):
                print("[NetworkClient.requestPublicNoContent] PUBLIC | \(method.rawValue) \(url.absoluteString) 오류가 발생했어요: \(statusCode)")
                completion(.failure(self.createNetworkError(response, error, statusCode)))
            }
        }
    }
    
    public func requestNoContent(
        endpointUrl: String,
        method: HTTPMethod,
        completion: @escaping (Result<Void, NetworkError>) -> Void)
    {
        self.requestNoContent(
            endpointUrl: endpointUrl,
            method: method,
            parameters: nil as String?,
            completion: completion)
    }
    
    public func requestNoContent<E: Encodable>(
        endpointUrl: String,
        method: HTTPMethod,
        parameters: E? = nil,
        completion: @escaping (Result<Void, NetworkError>) -> Void)
    {
        guard let url = URL(string: AppConfig.apiBaseUrl + endpointUrl) else {
            print("[NetworkClient.requestNoContent] '\(AppConfig.apiBaseUrl + endpointUrl)'은 유효하지 않은 URL이에요.")
            completion(.failure(.unknown("유효하지 않은 URL이에요.")))
            return
        }
        
        print("[NetworkClient.requestNoContent] \(method.rawValue) \(url.absoluteString) 요청 시도")
        
        let encoder: ParameterEncoder = (method == .get) || (method == .delete)
            ? Self.customUrlParameterEncoder
            : Self.springBootLocalDateTimeJsonParameterEncoder
        
        authSession.request(
            url,
            method: method,
            parameters: parameters,
            encoder: encoder)
        .validate(statusCode: 200 ..< 300)
        .response { response in
            let statusCode = response.response?.statusCode ?? 0
            
            switch response.result {
            case .success(_): completion(.success(()))
            case .failure(let error):
                print("[NetworkClient.requestNoContent] \(method.rawValue) \(url.relativePath) | 서버 오류예요(\(statusCode))")
                completion(.failure(self.createNetworkError(response, error, statusCode)))
            }
        }
    }
    
    private func performDecodableRequest<E: Encodable, D: Decodable>(
        session: Session,
        endpointUrl: String,
        method: HTTPMethod,
        parameters: E? = nil,
        encodingType: EncodingType = .auto,
        completion: @escaping (Result<D, NetworkError>
        ) -> Void)
    {
        guard let url = URL(string: AppConfig.apiBaseUrl + endpointUrl) else {
            print("[NetworkClient.performDecodableRequest] \(session === authSession ? "AUTH" : "PUBLIC") | '\(AppConfig.apiBaseUrl + endpointUrl)'은 유효하지 않은 URL이에요.")
            completion(.failure(.unknown("유효하지 않은 URL이에요.")))
            return
        }
        
        print("[NetworkClient.performDecodableRequest] \(session === authSession ? "AUTH" : "PUBLIC") | \(method.rawValue) \(url.absoluteString) 요청 시도")
        let encoder = getEncoder(method: method, type: encodingType)
        
        session.request(
                url,
                method: method,
                parameters: parameters,
                encoder: encoder)
            .validate(statusCode: 200 ..< 300)
            .responseDecodable(of: D.self, decoder: Self.springBootLocalDateTimeJsonDecoder) { response in
                let statusCode = response.response?.statusCode ?? 0
                switch response.result {
                case .success(let response): completion(.success(response))
                case .failure(let error):
                    print("[NetworkClient.performDecodableRequest] \(session === self.authSession ? "AUTH" : "PUBLIC") | \(method.rawValue) \(url.absoluteString) 오류가 발생했어요: \(statusCode)")
                    completion(.failure(self.createNetworkError(response, error, statusCode)))
                }
            }
    }
}


enum EncodingType {
    case auto
    case json
    case url
}
