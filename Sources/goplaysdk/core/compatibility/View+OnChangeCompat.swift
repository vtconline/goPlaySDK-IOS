//
//  View+OnChangeCompat.swift
//  goplaysdk
//
//  Created by pate on 15/1/26.
//

import SwiftUI
import Combine

extension View {

    @ViewBuilder
    public func onChangeCompat<T: Equatable>(
        of value: T,
        perform action: @escaping (T) -> Void
    ) -> some View {
        if #available(iOS 14.0, *) {
            self.onChange(of: value, perform: action)
        } else {
            self.onReceive(Just(value).removeDuplicates()) { newValue in
                action(newValue)
            }
        }
    }
}
