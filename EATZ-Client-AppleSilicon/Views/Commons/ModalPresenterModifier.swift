//
//  ModalPresenterModifier.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/7/25.
//

import SwiftUI
struct ModalPresenterModifier: ViewModifier {
    @EnvironmentObject var modalManager: ModalManager

    @State private var selectedModal: ModalRoute?
    @State private var isPresented: Bool = false
    @State private var isViewAppeared: Bool = false

    // 편의 바인딩: 현재 띄워야 할 스타일이 sheet인지?
    private var isSheetStyle: Bool {
        selectedModal?.style == .sheet
    }
    // 편의 바인딩: fullScreenCover 스타일인지?
    private var isFullScreenStyle: Bool {
        selectedModal?.style == .fullScreenCover
    }

    func body(content: Content) -> some View {
        content
            .onChange(of: modalManager.sheet) { newValue in
                // 최초 할당
                if selectedModal == nil {
                    selectedModal = newValue
                }
                // 이미 선택된 게 있는데 뷰가 가려진 상태면 초기화
                else if selectedModal != nil, isViewAppeared == false {
                    selectedModal = nil
                    isPresented = false
                }
            }
            .onChange(of: selectedModal) { newValue in
                // selectedModal이 nil이 아니면 무조건 present 트리거
                isPresented = (newValue != nil)
            }
            // 1) sheet 스타일일 때만 sheet modifier 활성
            .sheet(isPresented: Binding(
                get: { isPresented && isSheetStyle },
                set: { newVal in
                    // sheet 뚫고 내려갈 때
                    if !newVal {
                        selectedModal = nil
                        modalManager.sheet = nil
                    }
                    // isPresented 상태 동기화
                    isPresented = newVal
                }
            )) {
                selectedModal?.view
                    .onAppear  { isViewAppeared = true }
                    .onDisappear { isViewAppeared = false }
            }
            // 2) fullScreenCover 스타일일 때만 fullScreenCover modifier 활성
            .fullScreenCover(isPresented: Binding(
                get: { isPresented && isFullScreenStyle },
                set: { newVal in
                    if !newVal {
                        selectedModal = nil
                        modalManager.sheet = nil
                    }
                    isPresented = newVal
                }
            )) {
                selectedModal?.view
                    .onAppear  { isViewAppeared = true }
                    .onDisappear { isViewAppeared = false }
            }
    }
}

extension View {
    func modalPresenter() -> some View {
        modifier(ModalPresenterModifier())
    }
}
//struct ModalPresenterModifier: ViewModifier {
//    
//    @EnvironmentObject var modalManager: ModalManager
//    
//    @State private var selectedModal: ModalRoute?
//    @State private var isPresented: Bool = false
//    @State private var isViewAppeared: Bool = false
//    
//    func body(content: Content) -> some View {
//        content
//            .onChange(of: modalManager.sheet) { newValue in
//                if selectedModal == nil {
//                    selectedModal = newValue
//                }
//                else if selectedModal != nil, isViewAppeared == false {
//                    selectedModal = nil
//                    isPresented = false
//                }
//            }
//            .onChange(of: selectedModal) { newValue in
//                if selectedModal != nil {
//                    isPresented = true
//                } else {
//                    isPresented = false
//                }
//            }
//            .fullScreenCover(isPresented: $isPresented, onDismiss: {
//                cleanup()
//            }) {
//                
//            }
//            .sheet(isPresented: $isPresented, onDismiss: {
//                cleanup()
//            }) {
//                selectedModal?.view
//                    .onAppear {
//                        isViewAppeared = true
//                    }
//                    .onDisappear {
//                        isViewAppeared = false
//                    }
//            }
//    }
//    
//    private func cleanup() {
//        selectedModal = nil
//        modalManager.sheet = nil
//    }
//}
