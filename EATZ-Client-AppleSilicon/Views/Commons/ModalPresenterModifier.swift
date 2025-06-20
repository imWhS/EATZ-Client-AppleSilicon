//
//  ModalPresenterModifier.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/7/25.
//
// TODO: Alert 처리 
import SwiftUI

struct ModalPresenterModifier: ViewModifier {
    @EnvironmentObject var modalManager: ModalManager

    @State private var selectedModal: ModalRoute?
    @State private var isPresented: Bool = false
    @State private var isViewAppeared: Bool = false

    private var isSheetStyle: Bool {
        selectedModal?.style == .sheet
    }
    
    private var isFullScreenStyle: Bool {
        selectedModal?.style == .fullScreenCover
    }

    func body(content: Content) -> some View {
        content
            .onChange(of: modalManager.sheet) { newValue in
                if selectedModal == nil {
                    selectedModal = newValue
                }
                // 이미 모달이 화면에 표시되어 있으나, 다른 모달에 의해 가려진 상태면 초기화
                else if selectedModal != nil, isViewAppeared == false {
                    print("DBG selectedModal != nil, isViewAppeared == false")
                    selectedModal = nil
                    isPresented = false
                }
            }
            .onChange(of: selectedModal) { newValue in
                isPresented = (newValue != nil)
            }
            
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
