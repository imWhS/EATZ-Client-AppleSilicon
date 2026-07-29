//
//  ImageUtility.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 7/23/26.
//

import SwiftUI
import PhotosUI

enum PhotosPickerItemUtil {
    static func toUIImage(for item: PhotosPickerItem) async throws -> UIImage {
        guard let data = try await item.loadTransferable(type: Data.self) else {
            throw ProcessError.loadFailed
        }
        
        guard let uiImage = UIImage(data: data) else {
            throw ProcessError.invalidData
        }
        
        return uiImage
    }
    
    enum ProcessError: Error {
        case loadFailed
        case invalidData
        case error
    }
}
