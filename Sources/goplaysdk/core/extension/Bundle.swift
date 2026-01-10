//
//  Bundle.swift
//  goplaysdk
//
//  Created by pate on 10/1/26.
//

import Foundation
//for support cocoapod and Swift package manager too
extension Bundle {
    static var goplaysdk: Bundle {
        #if SWIFT_PACKAGE
        return .module
        #else
        return Bundle(for: GoPlaySDKBundleToken.self)
        #endif
    }
}

private final class GoPlaySDKBundleToken {}
