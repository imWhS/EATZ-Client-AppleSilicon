//
//  RecipeEditorDefaultInfoImageSection.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 7/6/26.
//

import SwiftUI
import PhotosUI

struct RecipeEditorDefaultInfoImageSection: View {
    @Binding var imageUrl: String
    @Binding var isProcessing: Bool
    @Binding var selectedPhotoItem: PhotosPickerItem?
    
    let onDeleteTapped: () -> Void
    
    init(imageUrl: Binding<String>, _ isProcessing: Binding<Bool>, _ selectedPhotoItem: Binding<PhotosPickerItem?>, _ onDeleteTapped: @escaping () -> Void) {
        self._imageUrl = imageUrl
        self._isProcessing = isProcessing
        self._selectedPhotoItem = selectedPhotoItem
        self.onDeleteTapped = onDeleteTapped
    }
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 20) {
                if isProcessing {
                    processingView
                } else if imageUrl.isEmpty {
                    placeholderView
                } else {
                    RecipeEditorImageView(imageUrl)
                }
                
                HStack {
                    if !(imageUrl.isEmpty) {
                        Button("대표 사진 삭제", action: onDeleteTapped)
                            .buttonStyle(SmallRoundedButtonStyle(type: isProcessing ? .disabled : .danger))
                    }
                    PhotosPicker(
                        selection: $selectedPhotoItem,
                        matching: .images,
                        photoLibrary: .shared()) {
                            Text(imageUrl.isEmpty ? "대표 사진 추가" : "대표 사진 변경")
                        }
                        .buttonStyle(SmallRoundedButtonStyle(type: isProcessing ? .disabled : .primary))
                }
                .disabled(isProcessing)
            }
            
            HorizontalDivider(padding: 0)
        }
        .padding(.horizontal, 20)
    }
    
    private var processingView: some View {
        RecipeEditorImageSectionContainer {
            ProgressView("대표 사진을 처리하고 있어요...")
                .foregroundStyle(Color.init(hex: "BEBEB9"))
        }
    }
    
    private var placeholderView: some View {
        RecipeEditorImageSectionContainer {
            VStack(spacing: 8) {
                Group {
                    Image("image")
                    Text("레시피의 대표 사진을 추가하세요.")
                        .font(.system(size: 17, weight: .medium))
                }
                .foregroundStyle(Color.init(hex: "BEBEB9"))
            }
        }
    }
}
