//
//  GoPlayHostingController.swift
//  goplaysdk
//
//  Created by pate on 8/1/26.
//
import SwiftUI
public final class GoPlayHostingController: UIHostingController<AnyView> {

    @objc public func close() {
//        dismiss(animated: true)
        //Bất kỳ chỗ nào gọi close() → PHẢI đảm bảo Main Thread -> use @MainActor
        Task { @MainActor in
                    self.dismiss(animated: true)
             }
    }
}

