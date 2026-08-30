//
//  CookableViewModel.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 10/2/25.
//

import Foundation
import Combine

class CookableViewModel: ObservableObject {
    @Published var searchCriteria: CookableSearchCriteria
    
    /// 화면에 표시할 sheet
    /// - 아무 sheet도 표시하지 않는 경우 `nil`이 됩니다.
    @Published var sheet: CookableSheet?
    
    var totalTimeLabel: String {
        guard let totalTimeInMinutes = searchCriteria.maxTotalTime else { return "설정" }
        return EatzDurationFormatter.minutes(from: totalTimeInMinutes) ?? "설정"
    }
    
    var servingsLabel: String {
        guard let servings = searchCriteria.servings else { return "설정" }
        return "\(servings)인"
    }
    
    private let auth: AuthProvider
    
    private var cancellables = Set<AnyCancellable>()
    private static let userDefaultsKey = "cookableSearchCriteria" // UserDefaults에 데이터를 저장하고, 불러올 때 사용할 고유 키

    init(auth: AuthProvider = AuthManager.shared) {
        self.auth = auth
        self.searchCriteria = Self.loadSearchCriteria()
        
        if !auth.isLoggedIn {
            self.searchCriteria.isCookableOnly = false
        }
        
        subscribeSeachCriteria()
    }
    
    func toggleCookableOnly() {
        auth.performWhenLoggedIn(perform: {
            self.searchCriteria.isCookableOnly.toggle()
        })
    }
    
    private func saveSearchCriteria(_ searchCriteria: CookableSearchCriteria) {
        if let encodedSearchCriteria = try? JSONEncoder().encode(searchCriteria) {
            UserDefaults.standard.set(encodedSearchCriteria, forKey: Self.userDefaultsKey)
        }
    }
    
    private func subscribeSeachCriteria() {
        $searchCriteria
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .sink { [weak self] searchCriteria in
                self?.saveSearchCriteria(searchCriteria)
            }
            .store(in: &cancellables)
    }

    private static func loadSearchCriteria() -> CookableSearchCriteria {
        if let savedSearchCriteriaData = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decodedSearchCriteria = try? JSONDecoder().decode(CookableSearchCriteria.self, from: savedSearchCriteriaData) {
            return decodedSearchCriteria
        } else {
            return CookableSearchCriteria()
        }
    }
}

enum CookableSheet: Identifiable {
    case totalTimePicker
    case servingsPicker
    
    var id: Self { self }
}
