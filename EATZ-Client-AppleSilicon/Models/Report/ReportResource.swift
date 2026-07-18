//
//  ReportResource.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 7/18/25.
//

import Foundation

struct ReportResource : Identifiable, Equatable, Encodable {
    let id: Int64
    let authorId: Int64
    let authorUsername: String
    let type: ResourceType
    let content: String
    let isContentTruncated: Bool
    
    private static let maxContentLength: Int = 100
    
    init(id: Int64, authorId: Int64, authorUsername: String, type: ResourceType, content: String) {
        self.id = id
        self.authorId = authorId
        self.authorUsername = authorUsername
        self.type = type
        
        if Self.maxContentLength < content.count {
            let truncatedContent = String(content.prefix(Self.maxContentLength))
            self.content = truncatedContent.trimmingCharacters(in: .whitespacesAndNewlines)
            self.isContentTruncated = true
        } else {
            self.content = content
            self.isContentTruncated = false
        }
    }
}
