//
//  Untitled.swift
//  goplaysdk
//
//  Created by Ngô Đồng on 23/4/25.
//

import SwiftUI

public struct HeaderView: View {
    public var body: some View {
        HStack {
            Spacer()
            Text("GoPlaySDK")
//                .font(.title)
                .font(.system(size: 32)) // 👈 Set specific font size
                .bold()
                
            Spacer()
        }
        .padding()
        .background(AppTheme.Colors.primary)
        .foregroundColor(.white)
    }
    
    public init() {}
}

public struct HeaderView_Previews: PreviewProvider {
    public static var previews: some View {
        HeaderView()
    }
}

