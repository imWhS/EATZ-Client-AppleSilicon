//
//  ThemePickerViewModel.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 10/9/25.
//

import SwiftUI

class ThemePickerViewModel: ObservableObject {
    @Published var featuredThemesState: TagThemesFeaturedState = .loading
    @Published var pagedThemes: Paged<TagTheme> = .initial
    
    @Published var showNavigationBarTitle = false
    @Published var alert: ThemePickerAlert?
    
    /// 화면에 표시될 데이터를 관리하는 모든 프로퍼티를 초기화하고, 초기 데이터를 불러옵니다.
    ///
    /// 아래와 같은 경우에 사용합니다.
    /// - 화면에 표시해야 할 데이터가 필요한 경우
    /// - 화면에 표시 중인 기존 데이터가 최신 상태를 반영하지 못하거나 필요 없어진 경우
    func resetAndLoadAll() {
        featuredThemesState = .loading
        pagedThemes = .initial
        pagedThemes.isLoadingNextPage = true
            
        loadFeaturedThemeGroups()
        loadAllThemes(page: 0) { self.pagedThemes.isLoadingNextPage = false }
    }
    
    func loadFeaturedThemeGroups() {
        ThemeService.shared.fetchAllThemesWithTags { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let themes): self.featuredThemesState = .loaded(themes: themes)
                case .failure(let networkError): self.featuredThemesState = .error(message: networkError.userMessage)
                }
            }
        }
    }
    
    func loadMoreAllThemes() {
        guard pagedThemes.hasNextPage, !pagedThemes.isLoadingNextPage else { return }
        pagedThemes.isLoadingNextPage = true
        
        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            loadAllThemes(page: pagedThemes.page + 1) {
                self.pagedThemes.isLoadingNextPage = false
            }
        }
    }
    
    func loadAllThemes(page: Int, completion: @escaping () -> Void = {}) {
        TagService.shared.fetchAllThemesTags(page: page) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { completion(); return }
                
                switch result {
                case .success(let response):
                    let newThemes = response.content
                    self.pagedThemes.appendPage(
                        newThemes,
                        page: response.page,
                        hasNextPage: response.hasNext,
                        totalElements: response.totalElements
                    )
                case .failure(let networkError):
                    if page == 0 {
                        self.pagedThemes.errorMessage = networkError.userMessage
                    } else {
                        self.alert = .error(message: networkError.userMessage)
                    }
                }
                completion()
            }
        }
    }
}

enum ThemePickerAlert: Identifiable {
    case error(message: String)
    
    var id: String {
        switch self {
        case .error: return "error"
        }
    }
    
    var alert: Alert {
        switch self {
        case .error(let message):
            return Alert(
                title: Text("오류"),
                message: Text(message),
                dismissButton: .default(Text("확인"))
            )
        }
    }
}
