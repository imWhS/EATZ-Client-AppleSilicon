//
//  TabHeaderView.swift
//  Eatz-AppleSilicon
//
//  Created by 손원희 on 4/6/25.
//

import SwiftUI

struct TabHeaderView: View {
    
    var title: String
    
    var buttons: [HeaderIconButton]
    
    var body: some View {
        HStack {
            Text(title)
                .font(Font.system(size: 38, weight: .bold))
                .padding(.leading)
            Spacer()
            HStack(spacing: 8) {
                ForEach(0 ..< buttons.count, id: \.self) { index in
                    buttons[index]
                }
            }
            .padding(.trailing)
        }
        .padding(.top, 20)
    }
    
}

#Preview {
    TabHeaderView(title: "레시피", buttons: [
        HeaderIconButton(title: "카테고리") {
            print("카테고리를 탭 했어요.")
        },
        HeaderIconButton(title: "설정") {
            print("설정을 탭 했어요.")
        },
        
    ])
}
