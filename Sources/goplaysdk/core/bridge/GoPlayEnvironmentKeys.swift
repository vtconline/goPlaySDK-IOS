//
//  AAAAA.swift
//  goplaysdk
//
//  Created by pate on 8/1/26.
//
import SwiftUI

// MARK: - Hosting Controller Environment

private struct GoPlayHostingControllerKey: EnvironmentKey {
    static let defaultValue: GoPlayHostingController? = nil
}

public extension EnvironmentValues {
    var hostingController: GoPlayHostingController? {
        get { self[GoPlayHostingControllerKey.self] }
        set { self[GoPlayHostingControllerKey.self] = newValue }
    }
}
