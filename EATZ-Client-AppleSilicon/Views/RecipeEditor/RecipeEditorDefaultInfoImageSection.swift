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
    @Binding var localImage: UIImage?
    @Binding var isProcessing: Bool
    @Binding var selectedPhotoItem: PhotosPickerItem?
    
    let onDeleteTapped: () -> Void
    
    private var hasImage: Bool {
        !imageUrl.isEmpty || localImage != nil
    }
    
    init(imageUrl: Binding<String>, _ localImage: Binding<UIImage?>, _ isProcessing: Binding<Bool>, _ selectedPhotoItem: Binding<PhotosPickerItem?>, _ onDeleteTapped: @escaping () -> Void) {
        self._imageUrl = imageUrl
        self._localImage = localImage
        self._isProcessing = isProcessing
        self._selectedPhotoItem = selectedPhotoItem
        self.onDeleteTapped = onDeleteTapped
    }
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 20) {
                imageSection
                interactionSection
            }
            
            HorizontalDivider(padding: 0)
        }
        .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    private var imageSection: some View {
        if isProcessing {
            processingView
        } else if let localImage = localImage {
            RecipeEditorImageView(localImage)
        } else if !imageUrl.isEmpty {
            RecipeEditorImageView(imageUrl)
        } else {
            placeholderView
        }
    }
    
    @ViewBuilder
    private var interactionSection: some View {
        HStack {
            if hasImage {
                Button("대표 사진 삭제", action: onDeleteTapped)
                    .buttonStyle(CapsuleButtonMediumStyle(status: isProcessing ? .disabled : .danger))
            }
            PhotosPicker(
                selection: $selectedPhotoItem,
                matching: .images,
                photoLibrary: .shared()) {
                    Text(hasImage ? "대표 사진 변경" : "대표 사진 선택")
                }
                .buttonStyle(CapsuleButtonMediumStyle(status: isProcessing ? .disabled : .primary))
        }
        .disabled(isProcessing)
    }
    
    private var processingView: some View {
        RecipeEditorImageSectionContainer {
            ProgressView("대표 사진을 처리하고 있어요...")
                .foregroundStyle(Color.gray20)
        }
    }
    
    private var placeholderView: some View {
        RecipeEditorImageSectionContainer {
            VStack(spacing: 8) {
                Group {
                    Image("image")
                    Text("보관함 또는 앨범에서 레시피의 대표 사진을 선택하세요.")
                        .font(.system(size: 17, weight: .medium))
                        .multilineTextAlignment(.center)
                }
                .foregroundStyle(Color.gray20)
            }
        }
    }
}
