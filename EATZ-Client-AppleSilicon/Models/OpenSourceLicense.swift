//
//  OpenSourceLicense.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 7/21/26.
//

import Foundation

struct OpenSourceLicense {
    let name: String
    let urlString: String
    let copyrightNotice: String
    let licenseType: String
    let licenseFullText: String
    
    var url: URL? { URL(string: urlString) }
}
