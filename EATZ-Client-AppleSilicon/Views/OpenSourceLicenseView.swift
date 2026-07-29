//
//  OpenSourceLicenseView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 7/21/26.
//

import SwiftUI

struct OpenSourceLicenseView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                header
                list
            }
            .frame(maxWidth: .infinity)
        }
        .background(Color.backgroundPrimary.ignoresSafeArea())
        .navigationTitle("Open Source License")
    }
    
    private var header: some View {
        VStack(alignment: .center, spacing: 20) {
            Image(systemName: "heart.fill")
                .resizable()
                .scaledToFit()
                .foregroundStyle(.pink)
                .frame(width: 40, height: 40)
            Group {
                Text("""
                The EATZ iOS client is made possible by the following open source projects.
                A huge thank you to all the developers for contributing to the open source ecosystem!
                """)
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.black)
                Text("""
                EATZ의 iOS 클라이언트는 아래 오픈 소스 프로젝트의 도움을 받아 만들어졌습니다.
                오픈 소스 생태계에 기여해주신 모든 개발자분들께 진심으로 감사드립니다!
                """)
                .font(.footnote)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 30)
    }
    
    private var list: some View {
        VStack(spacing: 0) {
            ForEach(OpenSourceLicenses.data.indices, id: \.self) { index in
                let license = OpenSourceLicenses.data[index]
                OpenSourceLicenseItem(license)
            }
        }
        .padding(.vertical, 10)
    }
}

private struct OpenSourceLicenseItem: View {
    let license: OpenSourceLicense
    
    init(_ license: OpenSourceLicense) {
        self.license = license
    }
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 20) {
                topSection
                HorizontalDivider(padding: 0)
                bottomSection
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(Color.white)
            .cornerRadius(8)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
        }
    }
    
    private var topSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(license.name)
                .font(.headline)
            if let url = license.url {
                Link(license.urlString, destination: url)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var bottomSection: some View {
        Text(license.licenseFullText)
            .font(.body)
    }
}
