//
//  StateObjectCompat.swift
//  goplaysdk
//
//  Created by pate on 15/1/26.
//

import Foundation
import SwiftUI


@MainActor
@propertyWrapper
public struct StateObjectCompat<ObjectType: ObservableObject>: DynamicProperty {

    @State private var stateObject: ObjectType
    @ObservedObject private var observedObject: ObjectType

    public init(wrappedValue: @autoclosure @escaping () -> ObjectType) {
        let object = wrappedValue()
        _stateObject = State(initialValue: object)
        _observedObject = ObservedObject(wrappedValue: object)
    }

    public var wrappedValue: ObjectType {
        if #available(iOS 14.0, *) {
            return stateObject
        } else {
            return observedObject
        }
    }
    
    public var projectedValue: ObservedObject<ObjectType>.Wrapper {
//        if #available(iOS 14.0, *) {
//            return .constant(_stateObject.projectedValue)
//        } else {
//            return _observedObject.projectedValue
//        }
        return _observedObject.projectedValue
//        _stateObject.projectedValue
//        _observedObject.projectedValue
    }

    // ❌ KHÔNG projectedValue
}

