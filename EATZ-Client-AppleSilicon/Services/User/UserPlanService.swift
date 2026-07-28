//
//  UserPlanService.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 8/5/25.
//

import Foundation
import Alamofire

final class UserPlanService {
    static let shared = UserPlanService()
    private lazy var networkClient = NetworkClient.shared
    
    private let commonEndpointUrl: String = "/v0/users/me/plans"
    
    private init() {}
    
    func createPlan(
        recipeId: Int64,
        date: Date,
        priority: Int,
        completion: @escaping (Result<PlanCreateResponse, NetworkError>) -> Void)
    {
        let request = PlanCreateRequest(recipeId: recipeId, date: date, priority: priority)
        networkClient.request(
            endpointUrl: "\(commonEndpointUrl)",
            method: .post,
            parameters: request,
            completion: completion)
    }
    
    func fetchPlannedDates(
        recipeId: Int64,
        startDate: Date,
        endDate: Date,
        completion: @escaping (Result<PlannedDateResponse, NetworkError>) -> Void)
    {
        let request = FetchPlannedDatesRequest(startDate: startDate, endDate: endDate)
        networkClient.request(
            endpointUrl: "\(commonEndpointUrl)/recipes/\(recipeId)/dates",
            method: .get,
            parameters: request,
            completion: completion)
    }
    
    func deletePlan(
        for id: Int64,
        completion: @escaping (Result<Void, NetworkError>) -> Void) {
        networkClient.requestNoContent(
            endpointUrl: "\(commonEndpointUrl)/\(id)",
            method: .delete,
            completion: completion)
    }
    
    func fetchPlans(
        startDate: Date,
        endDate: Date,
        completion: @escaping (Result<[PlannerPlan], NetworkError>) -> Void)
    {
        let request = FetchPlansRequest(startDate: startDate, endDate: endDate)
        networkClient.request(
            endpointUrl: "\(commonEndpointUrl)",
            method: .get,
            parameters: request,
            completion: completion)
    }
    
    func fetchChecklist(
        startDate: Date,
        endDate: Date,
        completion: @escaping (Result<Checklist, NetworkError>) -> Void
    ) {
        let request = FetchChecklistRequest(startDate: startDate, endDate: endDate)
        networkClient.request(
            endpointUrl: "\(commonEndpointUrl)/checklist",
            method: .get,
            parameters: request,
            completion: completion)
    }
}
