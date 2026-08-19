//
//  ChecklistViewModel.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 9/9/25.
//

import SwiftUI
import Alamofire

class ChecklistViewModel: ObservableObject {
    /// 뷰가 보여줄 화면 상태
    /// - 뷰의 최상위 서브뷰에서 보여줄 화면을 분기하기 위해 사용합니다.
    @Published var viewState: ChecklistViewState = .initialLoading
    
    @Published var checklist: Checklist?
    
    /// 화면에 표시할 alert
    /// - 아무 alert도 표시하지 않는 경우 `nil`이 됩니다.
    @Published var alert: ChecklistAlert?
    
    @Published var reportResource: ReportResource?
    
    @Published var showNavigationBarTitle = false
    
    @Published var isUpdatingPantry: Bool = false
    
    @Published var pendingIngredientIds: Set<Int64> = []
    
    @Published var pendingKitchenwareIds: Set<Int64> = []
    
    // MARK: - 공개 프로퍼티 (Public Properties)
    
    /// 체크리스트 데이터를 조회할 기준이 되는 날짜 범위(시작 날짜, 종료 날짜)입니다.
    ///
    /// PlannerView에서 계산된 확정된 기간을 주입받습니다.
    let dateRange: (startDate: Date, endDate: Date)
    
    var planCountLabel: String?  {
        guard let checklist = checklist else { return nil }
        return "\(checklist.cookable.plans.count + checklist.uncookable.plans.count)개의 플랜"
    }
    
    init(_ dateRange: (startDate: Date, endDate: Date)) {
        self.dateRange = dateRange
    }
    
    // MARK: - 의존성 (Dependencies)
    
    init(dateRange: (startDate: Date, endDate: Date)) {
        self.dateRange = dateRange
    }
    
    /// 화면에 표시될 데이터를 관리하는 모든 프로퍼티를 초기화하고, 초기 데이터를 불러옵니다.
    ///
    /// 아래와 같은 경우에 사용합니다.
    /// - 화면에 표시해야 할 데이터가 필요한 경우
    /// - 화면에 표시 중인 기존 데이터가 최신 상태를 반영하지 못하거나 필요 없어진 경우
    func resetAndLoadAll() {
        loadChecklist { self.viewState = .content }
    }
    
    func refresh() async {
        await withCheckedContinuation { continuation in
            loadChecklist { continuation.resume() }
        }
    }
}

extension ChecklistViewModel {
    func handleAddAllRequirementsToPantry() {
        guard case .content = viewState else { return }
        guard let checklist = checklist else { return }
        
        alert = .confirmAddingAllRequirementsToPantry(
            ingredientsCount: checklist.missingIngredientCount,
            kitchenwaresCount: checklist.missingKitchenwareCount,
            confirmAction: {
                self.addAllRequirementsToPantry()
            })
    }
    
    /// 체크리스트 데이터를 불러옵니다.
    func loadChecklist(onComplete: @escaping () -> Void = {}) {
        UserPlanService.shared.fetchChecklist(dateRange.startDate, dateRange.endDate) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let checklist):
                    self.viewState = .content
                    self.checklist = checklist
                case .failure(let networkError):
                    if self.checklist == nil {
                        self.viewState = .error(message: networkError.userMessage)
                    } else {
                        self.alert = .error(message: networkError.userMessage)
                    }
                }
                onComplete()
            }
        }
    }
    
    func handleKitchenwareItemAction(for id: Int64, action: ChecklistKitchenwareAction) {
        switch action {
        case  .addNote: print("addNote")
        default: updateKitchenware(for: id, action)
        }
    }
    
    func handleIngredientItemAction(for id: Int64, action: ChecklistIngredientAction) {
        switch action {
        case .addNote: print("setExpiryDate")
        case .setExpiryDate: print("setExpiryDate")
        default: updateIngredient(for: id, action)
        }
    }
    
    /// 체크리스트 속 특정 플랜에 대한 사용자 컨텍스트(저장/좋아요 등)의 상태를 변경하고,
    /// 변경된 상태를 `Checklist`에도 적용해 낙관적으로 UI 업데이트를 수행한 후 서버에 실제 상태 변경을 요청합니다.
    func updatePlan(for plan: ChecklistPlan, _ action: ChecklistPlanItemAction) {
        // 상태가 모두 변경됐을 때에만 체크리스트 관련 뷰를 재렌더링하기 위해, 상태 변경용 `Checklist` 를 정의합니다.
        guard var currentChecklist = checklist else { return }
        
        let recipeId = plan.recipeId
        let locations = findPlanLocationsByRecipe(in: currentChecklist, id: recipeId)
        guard let firstLocation = locations.first else { return }
        let originalPlan = getPlan(from: currentChecklist, at: firstLocation)
        
        // 낙관적으로 UI를 업데이트합니다.
        for location in locations {
            var plan = getPlan(from: currentChecklist, at: location)
            
            switch action {
            case .save: plan.savedRecipeByUser = true
            case .unsave: plan.savedRecipeByUser = false
            case .like: plan.likedRecipeByUser = true
            case .unlike: plan.likedRecipeByUser = false
            default: break
            }
            
            replace(plan, at: location, checklist: &currentChecklist)
        }
        
        checklist = currentChecklist
        switch action {
        case .save, .unsave: toggleSaveRecipeInPlan(recipeId, originalPlan, action)
        case .like, .unlike: toggleLikeRecipeInPlan(recipeId, originalPlan, action)
        default: break
        }
    }
    
    func handlePlanItemAction(plan: ChecklistPlan, action: ChecklistPlanItemAction) {
        switch action {
        case .report: reportRecipe(plan.recipeId, plan.recipeTitle, plan.recipeAuthorId, plan.recipeAuthorUsername)
        default: updatePlan(for: plan, action)
        }
    }
    
    private func addAllRequirementsToPantry() {
        guard case .content = viewState, let requirements = checklist?.uncookable.requirements else { return }
        
        UserPantryService.shared.addAllChecklistRequirements(requirements: requirements) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success: self.alert = .addedAllRequirementsToPantry(completion: {
                self.loadChecklist()
            })
            case .failure(let networkError): self.alert = .error(message: networkError.userMessage)
            }
        }
    }
    
    private func reportRecipe(_ recipeId: Int64, _ recipeTitle: String, _ recipeAuthorId: Int64, _ recipeAuthorUsername: String) {
        let resource = ReportResource(id: recipeId, authorId: recipeAuthorId, authorUsername: recipeAuthorUsername, type: .RECIPE, content: recipeTitle)
        reportResource = resource
    }
    
    private func toggleSaveRecipeInPlan(
        _ recipeId: Int64,
        _ originalPlan: ChecklistPlan,
        _ action: ChecklistPlanItemAction)
    {
        let completionHandler: (Result<Empty, NetworkError>) -> Void = { [weak self] result in
            guard let self = self else { return }
            if case .failure(let networkError) = result {
                self.alert = .error(message: networkError.userMessage)
                self.rollback(to: originalPlan)
            }
        }
        
        if case .save = action { UserService.shared.saveRecipe(for: recipeId, completion: completionHandler) }
        else if case .unsave = action { UserService.shared.unsaveRecipe(for: recipeId, completion: completionHandler) }
    }
    
    private func toggleLikeRecipeInPlan(
        _ recipeId: Int64,
        _ originalPlan: ChecklistPlan,
        _ action: ChecklistPlanItemAction)
    {
        let completionHandler: (Result<LikedRecipe, NetworkError>) -> Void = { [weak self] result in
            guard let self = self else { return }
            if case .failure(let networkError) = result {
                self.alert = .error(message: networkError.userMessage)
                self.rollback(to: originalPlan)
            }
        }
        
        if case .like = action { RecipeLikeService.shared.likeRecipe(for: recipeId, completion: completionHandler) }
        else if case .unlike = action { RecipeLikeService.shared.unlikeRecipe(for: recipeId, completion: completionHandler) }
    }
    
    /// 체크리스트 속 특정 도구에 대한 사용자 컨텍스트(보관함에 추가/보관함에서 제거 등)의 상태를 변경하고,
    /// 변경된 상태를 `Checklist`에도 적용해 낙관적으로 UI 업데이트를 수행한 후 서버에 실제 상태 변경을 요청합니다.
    private func updateKitchenware(for id: Int64, _ action: ChecklistKitchenwareAction) {
        // 상태가 모두 변경됐을 때에만 체크리스트 관련 뷰를 재렌더링하기 위해, 상태 변경용 `Checklist` 를 정의합니다.
        guard var currentChecklist = checklist else { return }
        
        // 모든 섹션 속에서 해당 도구의 모든 위치를 찾습니다.
        // 동일한 도구가 `Checklist`의 `cookable`과 `uncookable` 모두 존재할 수 있기 때문에,
        // 도구의 변경된 상태를 `Checklist`에 일괄 적용하기 위해 사용합니다.
        let locations = findKitchenwareLocations(in: currentChecklist, id: id)
        
        // 상태 변경 전의 도구를 별도로 보관합니다. 도구 상태 변경 실패 시, 낙관적 업데이트된 UI를 원상 복구할 때 사용합니다.
        guard let firstLocation = locations.first else { return }
        
        if pendingKitchenwareIds.contains(id) { return }
        pendingKitchenwareIds.insert(id)
        
        if isUpdatingPantry { return }
        isUpdatingPantry = true
        
        let originalKitchenware = getKitchenware(from: currentChecklist, at: firstLocation)
        
        // 낙관적으로 UI를 업데이트합니다.
        for location in locations {
            var kitchenware = getKitchenware(from: currentChecklist, at: location)
            switch action {
            case .addToPantry: kitchenware.missing = false
            case .removeFromPantry: kitchenware.missing = true
            default: break
            }
            replace(kitchenware, at: location, checklist: &currentChecklist)
        }
        
        checklist = currentChecklist
        updatePantryStatus(for: id, originalKitchenware, action)
    }
    
    /// 체크리스트 속 특정 재료에 대한 사용자 컨텍스트(보관함에 추가/보관함에서 제거/좋아요 등)의 상태를 변경하고,
    /// 변경된 상태를 `Checklist`에도 적용해 낙관적으로 UI 업데이트를 수행한 후 서버에 실제 상태 변경을 요청합니다.
    private func updateIngredient(for id: Int64, _ action: ChecklistIngredientAction) {
        // 상태가 모두 변경됐을 때에만 체크리스트 관련 뷰를 재렌더링하기 위해, 상태 변경용 `Checklist` 를 정의합니다.
        guard var currentChecklist = checklist else { return }

        // 모든 섹션 속에서 해당 재료의 모든 위치를 찾습니다.
        // 동일한 재료가 `Checklist`의 `cookable`과 `uncookable` 모두 존재할 수 있기 때문에,
        // 재료의 변경된 상태를 `Checklist`에 일괄 적용하기 위해 사용합니다.
        let locations = findIngredientLocations(in: currentChecklist, id: id)
        
        // 상태 변경 전의 재료를 별도로 보관합니다. 재료 상태 변경 실패 시, 낙관적 업데이트된 UI를 원상 복구할 때 사용합니다.
        guard let firstLocation = locations.first else { return }
        
        guard !pendingIngredientIds.contains(id) else { return }
        pendingIngredientIds.insert(id)
        
        guard !isUpdatingPantry else { return }
        isUpdatingPantry = true
        
        let originalIngredient = getIngredient(from: currentChecklist, at: firstLocation)
        
        // 낙관적으로 UI를 업데이트합니다.
        for location in locations {
            var ingredient = getIngredient(from: currentChecklist, at: location)
            switch action {
            case .addToPantry: ingredient.missing = false
            case .removeFromPantry: ingredient.missing = true
            case .like: ingredient.likedByUser = true
            case .unlike: ingredient.likedByUser = false
            default: break
            }
            replace(ingredient, at: location, checklist: &currentChecklist)
        }
        
        checklist = currentChecklist
        switch action {
        case .addToPantry, .removeFromPantry: updatePantryStatus(for: id, originalIngredient, action)
        case .like, .unlike: toggleLikeIngredient(for: id, originalIngredient, action)
        default: break
        }
    }
    
    private func updatePantryStatus(
        for id: Int64,
        _ originalIngredient: ChecklistIngredient,
        _ action: ChecklistIngredientAction)
    {
        let completionHandler: (Result<Void, NetworkError>) -> Void = { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success:
                    self.loadChecklist {
                        self.pendingIngredientIds.remove(id)
                        self.isUpdatingPantry = false
                    }
                case .failure(let networkError):
                    self.pendingIngredientIds.remove(id)
                    self.isUpdatingPantry = false
                    self.alert = .itemUpdateFailed(message: networkError.userMessage)
                    self.rollback(to: originalIngredient)
                }
            }
        }
        
        switch action {
        case .addToPantry: UserPantryService.shared.addIngredients(ids: [id], completion: completionHandler)
        case .removeFromPantry: UserPantryService.shared.removeIngredients(ids: [id], completion: completionHandler)
        default: break
        }
    }
    
    private func updatePantryStatus(
        for id: Int64,
        _ originalKitchenware: ChecklistKitchenware,
        _ action: ChecklistKitchenwareAction)
    {
        let completionHandler: (Result<Void, NetworkError>) -> Void = { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success:
                    self.loadChecklist {
                        self.pendingKitchenwareIds.remove(id)
                        self.isUpdatingPantry = false
                    }
                case .failure(let networkError):
                    self.pendingKitchenwareIds.remove(id)
                    self.isUpdatingPantry = false
                    self.alert = .itemUpdateFailed(message: networkError.userMessage)
                    self.rollback(to: originalKitchenware)
                }
            }
        }
        
        switch action {
        case .addToPantry: UserPantryService.shared.addKitchenwares(ids: [id], completion: completionHandler)
        case .removeFromPantry: UserPantryService.shared.removeKitchenwares(ids: [id], completion: completionHandler)
        default: break
        }
    }
    
    private func toggleLikeIngredient(
        for id: Int64,
        _ originalIngredient: ChecklistIngredient,
        _ action: ChecklistIngredientAction)
    {
        let completionHandler: (Result<LikedIngredient, NetworkError>) -> Void = { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success:
                    self.loadChecklist {
                        self.pendingIngredientIds.remove(id)
                        self.isUpdatingPantry = false
                    }
                case .failure(let networkError):
                    self.alert = .itemUpdateFailed(message: networkError.userMessage)
                    self.rollback(to: originalIngredient)
                }
            }
        }
        
        switch action {
        case .like: IngredientLikeService.shared.likeIngredient(for: id, completion: completionHandler)
        case .unlike: IngredientLikeService.shared.unlikeIngredient(for: id, completion: completionHandler)
        default: break
        }
    }
    
    /// `Checklist`에서 `RequirementLocation`이 가리키는 위치의 `ChecklistPlan`을 가져옵니다.
    private func getPlan(from checklist: Checklist, at location: ChecklistLocation) -> ChecklistPlan {
        switch location.cookability {
        case .cookable: return checklist.cookable.plans[location.index]
        case .uncookable: return checklist.uncookable.plans[location.index]
        }
    }
    
    /// `Checklist`에서 `ChecklistLocation`이 가리키는 위치의 `ChecklistKitchenwareListItem`을 가져옵니다.
    private func getKitchenware(from checklist: Checklist, at location: ChecklistLocation) -> ChecklistKitchenware {
        switch location.cookability {
        case .cookable: return checklist.cookable.requirements.kitchenwares[location.index]
        case .uncookable: return checklist.uncookable.requirements.kitchenwares[location.index]
        }
    }
    
    /// `Checklist`에서 `ChecklistLocation`이 가리키는 위치의 `ChecklistIngredientListItem`을 가져옵니다.
    private func getIngredient(from checklist: Checklist, at location: ChecklistLocation) -> ChecklistIngredient {
        switch location.cookability {
        case .uncookable: return checklist.uncookable.requirements.ingredients[location.index]
        case .cookable: return checklist.cookable.requirements.ingredients[location.index]
        }
    }
    
    /// `Checklist`에서 `location`이 가리키는 위치에 해당하는 플랜을`plan`으로 교체합니다.
    private func replace(
        _ plan: ChecklistPlan,
        at location: ChecklistLocation,
        checklist: inout Checklist)
    {
        switch location.cookability {
        case .uncookable: checklist.uncookable.plans[location.index] = plan
        case .cookable: checklist.cookable.plans[location.index] = plan
        }
    }
    
    /// `Checklist`에서 `location`이 가리키는 위치에 해당하는 재료를`ingredient`로 교체합니다.
    private func replace(
        _ ingredient: ChecklistIngredient,
        at location: ChecklistLocation,
        checklist: inout Checklist)
    {
        switch location.cookability {
        case .uncookable: checklist.uncookable.requirements.ingredients[location.index] = ingredient
        case .cookable: checklist.cookable.requirements.ingredients[location.index] = ingredient
        }
    }
    
    /// `Checklist`에서 `location`이 가리키는 위치에 해당하는 도구를`kitchenware`로 교체합니다.
    private func replace(
        _ kitchenware: ChecklistKitchenware,
        at location: ChecklistLocation,
        checklist: inout Checklist)
    {
        switch location.cookability {
        case .uncookable: checklist.uncookable.requirements.kitchenwares[location.index] = kitchenware
        case .cookable: checklist.cookable.requirements.kitchenwares[location.index] = kitchenware
        }
    }
    
    /// `Checklist`에서 레시피의 ID `id`에 해당하는 플랜(ID에 해당하는 레시피가 추가되어 있는 플랜)의 모든 위치를 찾습니다.
    ///
    /// `Checklist` 내 `uncookable.plans`, `cookable.plans`에서 `id`에 해당하는 레시피가 추가된
    /// 모든 플랜의 섹션, 인덱스를 찾아 `RequirementLocation` 타입으로 반환합니다.
    private func findPlanLocationsByRecipe(in checklist: Checklist, id: Int64) -> [ChecklistLocation] {
        var locations: [ChecklistLocation] = []
        
        // `Checklist.uncookable`의 모든 레시피를 `(index, plan)` 튜플화 한 후, `index`만 추출해
        // `recipeId`에 대한 모든 요리 불가능 레시피를 포함하는 플랜 인덱스 목록으로 만듭니다.
        let uncookableIndexes = checklist.uncookable.plans.enumerated()
            .filter { $0.element.recipeId == id }
            .map { $0.offset }
        
        // 요리 불가능 레시피를 포함하는 플랜 인덱스 목록을 [ChecklistLocation]으로 변환 후, `locations`에 추가합니다.
        locations.append(contentsOf: uncookableIndexes.map {
            ChecklistLocation(cookability: .uncookable, index: $0)
        } )
        
        // `Checklist.cookable`의 모든 레시피를 `(index, plan)` 튜플화 한 후, `index`만 추출해
        // `recipeId`에 대한 모든 요리 가능 레시피를 포함하는 플랜 인덱스 목록으로 만듭니다.
        let cookableIndexes = checklist.cookable.plans.enumerated()
            .filter { $0.element.recipeId == id }
            .map { $0.offset }
        
        // 요리 가능 레시피를 포함하는 플랜 인덱스 목록을 [ChecklistLocation]으로 변환 후, `locations`에 추가합니다.
        locations.append(contentsOf: cookableIndexes.map {
            ChecklistLocation(cookability: .cookable, index: $0)
        } )
        
        return locations
    }
    
    /// `Checklist`에서 `kitchenwareId`에 해당하는 도구의 모든 위치를 찾습니다.
    ///
    /// `Checklist` 내 `uncookable.requirements.kitchenwares`, `cookable.requirements.kitchenwares`에서
    /// 도구의 모든 섹션, 인덱스를 찾아 `RequirementLocation` 타입으로 반환합니다.
    private func findKitchenwareLocations(in checklist: Checklist, id: Int64) -> [ChecklistLocation] {
        var locations: [ChecklistLocation] = []
        
        if let index = checklist.uncookable.requirements.kitchenwares.firstIndex(where: { $0.id == id }) {
            locations.append(ChecklistLocation(cookability: .uncookable, index: index))
        }
        
        if let index = checklist.cookable.requirements.kitchenwares.firstIndex(where: { $0.id == id }) {
            locations.append(ChecklistLocation(cookability: .cookable, index: index))
        }
        
        return locations
    }
    
    /// `Checklist`에서 `ingredientId`에 해당하는 재료의 모든 위치를 찾습니다.
    ///
    /// `Checklist` 내 `uncookable.requirements.ingredients`, `cookable.requirements.ingredients`에서
    /// 재료의 모든 섹션, 인덱스를 찾아 `RequirementLocation` 타입으로 반환합니다.
    private func findIngredientLocations(in checklist: Checklist, id: Int64) -> [ChecklistLocation] {
        var locations: [ChecklistLocation] = []
        
        if let index = checklist.uncookable.requirements.ingredients.firstIndex(where: { $0.id == id }) {
            locations.append(ChecklistLocation(cookability: .uncookable, index: index))
        }
        
        if let index = checklist.cookable.requirements.ingredients.firstIndex(where: { $0.id == id }) {
            locations.append(ChecklistLocation(cookability: .cookable, index: index))
        }
        
        return locations
    }
    
    // UI를 낙관적으로 업데이트하기 위해 바꿨던 플랜의 상태를 `original` 상태로 되돌립니다.
    private func rollback(to original: ChecklistPlan) {
        // 상태가 모두 변경됐을 때에만 체크리스트 관련 뷰를 재렌더링하기 위해, 상태 변경용 `Checklist` 를 정의합니다.
        guard var currentChecklist = checklist else { return }
        
        // 롤백 메서드가 서버 요청 후 비동기적으로 호출되어지기 때문에, 그 사이에 `Checklist`의 상태가
        // 변경됐을 수 있음을 고려해 `Checklist` 속 플랜의 위치를 다시 찾습니다.
        let locations = findPlanLocationsByRecipe(in: currentChecklist, id: original.recipeId)
        for location in locations {
            var plan = getPlan(from: currentChecklist, at: location)
            plan.savedRecipeByUser = original.savedRecipeByUser
            plan.likedRecipeByUser = original.likedRecipeByUser
            replace(plan, at: location, checklist: &currentChecklist)
        }
        checklist = currentChecklist
    }
    
    // UI를 낙관적으로 업데이트하기 위해 바꿨던 도구의 상태를 `original` 상태로 되돌립니다.
    private func rollback(to original: ChecklistKitchenware) {
        // 상태가 모두 변경됐을 때에만 체크리스트 관련 뷰를 재렌더링하기 위해, 상태 변경용 `Checklist` 를 정의합니다.
        guard var currentChecklist = checklist else { return }
        
        // 롤백 메서드가 서버 요청 후 비동기적으로 호출되어지기 때문에, 그 사이에 `Checklist`의 상태가
        // 변경됐을 수 있음을 고려해 `Checklist` 속 도구의 위치를 다시 찾습니다.
        let locations = findKitchenwareLocations(in: currentChecklist, id: original.id)
        for location in locations {
            var kitchenware = getKitchenware(from: currentChecklist, at: location)
            kitchenware.missing = original.missing
            replace(kitchenware, at: location, checklist: &currentChecklist)
        }
        checklist = currentChecklist
    }
    
    // UI를 낙관적으로 업데이트하기 위해 바꿨던 재료의 상태를 `original` 상태로 되돌립니다.
    private func rollback(to original: ChecklistIngredient) {
        // 상태가 모두 변경됐을 때에만 체크리스트 관련 뷰를 재렌더링하기 위해, 상태 변경용 `Checklist` 를 정의합니다.
        guard var currentChecklist = checklist else { return }
        
        // 롤백 메서드가 서버 요청 후 비동기적으로 호출되어지기 때문에, 그 사이에 `Checklist`의 상태가
        // 변경됐을 수 있음을 고려해 `Checklist` 속 재료의 위치를 다시 찾습니다.
        let locations = findIngredientLocations(in: currentChecklist, id: original.id)
        for location in locations {
            var ingredient = getIngredient(from: currentChecklist, at: location)
            ingredient.missing = original.missing
            ingredient.likedByUser = original.likedByUser
            replace(ingredient, at: location, checklist: &currentChecklist)
        }
        checklist = currentChecklist
    }
}

enum ChecklistViewState {
    case initialLoading
    case content
    case error(message: String)
}

/// `checklist`를 구성하는 2개의 섹션을 구분하기 위한 타입입니다.
private enum ChecklistCookabilityType {
    case cookable, uncookable
}

/// `Checklist` 데이터 모델 내에서 재료, 도구와 같은 아이템의 위치를 특정하는 '좌표' 역할을 합니다.
private struct ChecklistLocation {
    let cookability: ChecklistCookabilityType
    let index: Int
}
