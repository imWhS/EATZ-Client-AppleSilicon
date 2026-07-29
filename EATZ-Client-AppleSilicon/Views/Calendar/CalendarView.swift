//
//  CalendarView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 8/8/25.
//

import SwiftUI
import FSCalendar

struct CalendarView: UIViewRepresentable {
    /// 선택된 날짜 목록입니다.
    @Binding private var selectedDates: [Date]
    
    /// 화면에 표시하고 있는 달력의 '월'입니다.
    @Binding private var currentMonth: Date
    
    /// 날짜 선택 모드입니다.
    private let mode: CalendarSelectionMode
    
    /// 선택을 비활성화해야 하는 날짜 목록입니다.
    private let disabledDates: Set<Date>?
    
    /// 달력의 '월' 변경 발생 시 이벤트 콜백 클로저입니다.
    private let onMonthDidChange: ((Date) -> Void)?
    
    init(
        _ selectedDates: Binding<[Date]>,
        _ currentMonth: Binding<Date>,
        _ mode: CalendarSelectionMode,
        _ disabledDates: Set<Date>? = nil,
        onMonthDidChange: ((Date) -> Void)? = nil) {
        self._selectedDates = selectedDates
        self._currentMonth = currentMonth
        self.mode = mode
        self.disabledDates = disabledDates
        self.onMonthDidChange = onMonthDidChange
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    /// FSCalendar의 인스턴스를 생성한 후, 기본적인 항목 및 디자인을 설정합니다.
    func makeUIView(context: Context) -> FSCalendar {
        let calendar = FSCalendar()
        
        calendar.delegate = context.coordinator
        calendar.dataSource = context.coordinator
        calendar.register(CalendarCell.self, forCellReuseIdentifier: "cell")
        
        switch mode {
        case .single: calendar.allowsMultipleSelection = false
        case .range, .multiple: calendar.allowsMultipleSelection = true
        }
        
        calendar.scope = .month
        calendar.locale = Locale(identifier: "ko_KR")
        calendar.scrollDirection = .horizontal
        calendar.swipeToChooseGesture.isEnabled = false
        
        calendar.headerHeight = 0
        calendar.weekdayHeight = 0
        calendar.calendarHeaderView.removeFromSuperview()
        calendar.calendarWeekdayView.removeFromSuperview()
        
        configureCalendarAppearance(calendar)
        
        if let layout = calendar.collectionView.collectionViewLayout as? FSCalendarCollectionViewLayout {
            layout.sectionInsets = .init(top: 0, left: 15, bottom: 0, right: 15)
        }

        return calendar
    }
    
    /// CalendarView의 변경 사항을 FSCalendar에 동기화합니다.
    func updateUIView(_ uiView: FSCalendar, context: Context) {
        // 현재 '월'을 동기화합니다.
        if !Calendar.current.isDate(uiView.currentPage, inSameDayAs: currentMonth) {
            uiView.setCurrentPage(currentMonth, animated: true)
        }
        
        // 선택된 날짜 목록을 동기화합니다. FSCalendar의 기존 날짜 선택 상태를 초기화한 후, selectedDates에 해당하는 날짜로 설정합니다.
        let newSelectedDates = Set(selectedDates.map { Calendar.current.startOfDay(for: $0) })
        let currentSelectedDates = Set(uiView.selectedDates.map { Calendar.current.startOfDay(for: $0)})
        if newSelectedDates != currentSelectedDates {
            currentSelectedDates.forEach { currentSelectedDate in uiView.deselect(currentSelectedDate) }
            newSelectedDates.forEach { newSelectedDate in uiView.select(newSelectedDate, scrollToDate: false) }
            //            uiView.reloadData() TODO: 선택 해제된 셀 선택 상태 이슈
        }
        
        // Coordinator가 참조 중인 이전 CalendarView의 disabledDates(disabledDates의 과거 값)를 가져와 캡처합니다.
        let lastDisabledDates = context.coordinator.parent.disabledDates
        
        // FSCalendar의 data source이기도 한 Coordinator가 새 데이터(상태)를 요청받았을 때,
        // disabledDates와 같은 CalendarView의 최신 데이터를 참조할 수 있도록
        // Coordinator의 parent를 현재 CalendarView로 업데이트합니다.
        // 단, disabledDates 뿐 아니라 mode 등의 변경 사항을 반영해야 할 수 있기 때문에,
        // CalendarView에 변경 사항이 발생할 때마다 실행해야 합니다.
        context.coordinator.parent = self
        
        // 현재 FSCalendar의 화면 표시를 위한 주요 데이터가 변경됐을 때에만
        // FSCalendar의 레이아웃과 모든 셀을 재생성합니다.
        if newSelectedDates != currentSelectedDates || disabledDates != lastDisabledDates {
            uiView.visibleCells().forEach { cell in
                cell.configureAppearance()
            }
        }
    }
    
    private func configureCalendarAppearance(_ calendar: FSCalendar) {
        calendar.appearance.titleFont = .systemFont(ofSize: 18)
        calendar.appearance.weekdayTextColor = .black
        calendar.appearance.titleDefaultColor = .black
        calendar.appearance.titleSelectionColor = .white
    }
    
    class Coordinator: NSObject, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
        var parent: CalendarView
        
        private var firstDate: Date? = nil
        private var lastDate: Date? = nil
        
        init(_ parent: CalendarView) {
            self.parent = parent
        }
        
        // MARK: - FSCalendar delegate 메서드
        
        /// FSCalendar가 화면에 날짜를 표시할 때 사용할 셀(FSCalendarCell)을 생성합니다.
        /// 또한, 셀의 비활성화 상태 표시 여부와 같은 UI 상태를 구성합니다.
        func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
            let cell = calendar.dequeueReusableCell(withIdentifier: "cell", for: date, at: position) as! CalendarCell
            
            // 날짜를 비교할 때 불필요한 시간(시, 분, 초)을 제거한 Date 인스턴스를 생성합니다.
            let targetDate = Calendar.current.startOfDay(for: date)
            
            // UI에서 FSCalendarCell의 비활성화 상태 표시 여부를 설정합니다.
            let isDisabled = parent.disabledDates?.contains(targetDate) ?? false
            cell.isDisabled = isDisabled
            
            return cell
        }
        
        /// FSCalendar의 특정 날짜 셀을 탭했을 때, 해당 날짜의 선택 가능 여부를 결정합니다.
        /// 비활성화 날짜 선택을 방지합니다.
        func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
            let targetDate = Calendar.current.startOfDay(for: date)
            let isDisabled = parent.disabledDates?.contains(targetDate) ?? false
            return !isDisabled
        }
        
        /// FSCalendar에서 특정 날짜 셀이 선택 상태가 된 직후에 호출됩니다.
        /// 선택된 날짜 데이터에서 시작 날짜(`startDate`)와 끝 날짜(`endDate`)를 추출하고, 선택된 날짜 목록`selectedDates`)에 반영한 후 CalendarView에 동기화합니다.
        func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
            handleSelection(date)
        }

        /// FSCalendar에서 기존 선택 상태인 셀을 탭해서, 선택 상태가 해제된 직후에 호출됩니다.
        /// 기간 선택 모드(`CalendarDateSelectionMode.range`)라면 선택 관련 상태를 모두 초기화한 후 CalendarView에도 동기화합니다.
        func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
            switch parent.mode {
            case .multiple: handleSelection(date)
            default: resetSelection()
            }
        }
        
        func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
            // 먼저 SwiftUI의 currentMonth 상태를 업데이트합니다.
            DispatchQueue.main.async {
                self.parent.currentMonth = calendar.currentPage
            }
            
            // 그 다음, parent를 통해 전달받은 '데이터 불러오기' 클로저를 호출합니다.
            parent.onMonthDidChange?(calendar.currentPage)
        }
        
        // MARK: - 날짜 선택 처리 메서드

        private func handleSelection(_ date: Date) {
            if let disabledDates = parent.disabledDates, disabledDates.contains(date) { return }
            
            switch parent.mode {
            case .single: handleSingleSelection(date)
            case .range: handleRangeSelection(date)
            case .multiple: handleMultipleSelection(date)
            }
        }
        
        /// 단일 날짜 선택 모드일 때, 특정 날짜의 선택을 처리합니다.
        private func handleSingleSelection(_ date: Date) {
            parent.selectedDates = [date]
        }
        
        /// 기간 선택 모드일 때,  특정 날짜를 탭 액션을 처리합니다.
        /// - 현재 선택 상태(시작 날짜/마지막 날짜 유무)에 따라 새로운 시작 날짜를 설정하거나, 마지막 날짜를 설정해서 날짜 범위를 구성합니다.
        /// - 날짜 범위가 구성되면, 범위에 속하는 모든 날짜를 선택된 날짜 목록으로 구성합니다.
        /// - 시작 날짜로 1개의 날짜만 선택된 경우, 해당 날짜만으로 선택된 날짜 목록을 구성합니다.
        private func handleRangeSelection(_ date: Date) {
            // 아무 날짜도 선택되지 않은 상태인 경우(새 날짜를 최초로 탭한 경우): 새 날짜를 시작 날짜로 설정하고 선택된 상태로 바꿉니다.
            if firstDate == nil && lastDate == nil {
                firstDate = date
                lastDate = nil
                parent.selectedDates = [firstDate!]
                return
            }
            
            // 시작 날짜만 선택된 상태인 경우(기존 선택된 날짜가 시작 날짜로서 1개 존재하는 상태에서 새 날짜를 탭한 경우)
            if firstDate != nil && lastDate == nil {
                // 새 날짜가 기존 선택된 날짜보다 이후 시점인 경우: 새 날짜를 마지막 날짜로 설정합니다.
                if firstDate! <= date {
                    lastDate = date
                } else {
                    // 새 날짜가 기존 선택된 날짜보다 이른 시점인 경우: 기존 선택된 날짜(시작 날짜)를 마지막 날짜로, 새 날짜를 시작 날짜로 설정합니다.
                    lastDate = firstDate
                    firstDate = date
                }
                
                // 시작 날짜부터 마지막 날짜 사이의 모든 날짜를 일괄 선택 처리합니다.
                parent.selectedDates = generateDates(from: firstDate!, to: lastDate!)
                return
            }
            
            // 시작 날짜와 마지막 날짜 모두 선택된 상태인 경우: 기존 날짜 선택 상태를 모두 초기화하고, 새 날짜를 시작 날짜로 설정합니다.
            firstDate = date
            lastDate = nil
            parent.selectedDates = [firstDate!]
        }
        
        /// 날짜 개별 다중 선택 모드일 때, 특정 날짜의 선택을 처리합니다.
        private func handleMultipleSelection(_ date: Date) {
            if !parent.selectedDates.contains(date) {
                parent.selectedDates.append(date)
            } else {
                if let index = parent.selectedDates.firstIndex(of: date) {
                    parent.selectedDates.remove(at: index)
                }
            }
        }
        
        /// 모든 날짜 선택 상태를 초기화합니다.
        private func resetSelection() {
            firstDate = nil
            lastDate = nil
            parent.selectedDates.removeAll()
        }
        
        /// 시작 날짜부터 종료 날짜까지의 모든 날짜를 생성한 후, 배열로 반환합니다.
        private func generateDates(from firstDate: Date, to lastDate: Date) -> [Date] {
            var dateRange: [Date] = []
            var currentDate = firstDate
            while currentDate <= lastDate {
                let isDisabledDate = parent.disabledDates?.contains(currentDate) ?? false
                if !isDisabledDate {
                    dateRange.append(currentDate)
                }
                currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
            }
            
            return dateRange
        }
    }
}

/// 달력에서의 날짜 선택 모드를 정의합니다.
enum CalendarSelectionMode {
    case single // 단일 날짜 선택 모드
    case range // 기간 선택 모드
    case multiple // 날짜 개별 다중 선택 모드
}
