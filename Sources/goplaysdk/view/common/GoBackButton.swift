//
//  GoBackButton.swift
//  goplaysdk
//
//  Created by Ngô Đồng on 25/4/25.
//

import SwiftUI

public struct GoBackButton: View {
    @Environment(\.dismiss) var dismiss
    var txt: String = ""
    var customAction: (() -> Void)?
    public var body: some View {
        HStack {
            Button(action: {
                if let customAction = customAction {
                    customAction()
                } else {
                    dismiss()
                }
            }) {
                HStack {
                    Image(systemName: "chevron.left")
                    if(!txt.isEmpty){
                        Text(txt)
                    }
                }
            }
            Spacer()
        }
        .padding()
    }
    
    public init(text: String = "Quay lại",action: (() -> Void)? = nil) {
        self.txt = text
        self.customAction = action
    }
}
