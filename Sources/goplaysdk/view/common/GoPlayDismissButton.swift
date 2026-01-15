//
//  GoPlayDismissButton.swift
//  goplaysdk
//
//  Created by pate on 15/1/26.
//

import SwiftUI


public struct GoPlayDismissButton: View {
    public var body: some View {
        if #available(iOS 15.0, *) {
            DismissButtonIOS15()
        } else {
            DismissButtonLegacy()
        }
    }
}
@available(iOS 15.0, *)
private struct DismissButtonIOS15: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        Button( action:{
            dismiss()
        }) {
            HStack {
                Image(systemName: "chevron.left")
                Text("Quay lại")  // ← Custom back button text
            }
        }
    }
}

private struct DismissButtonLegacy: View {
    @Environment(\.presentationMode) private var presentationMode
    var body: some View {
        Button {
            presentationMode.wrappedValue.dismiss()
        } label: {
            Image(systemName: "chevron.left")
        }
    }
}

