//
//  MemoryUserStore.swift
//  goplaysdk
//
//  Created by pate on 14/1/26.
//


public final class MemoryUserStore: UserStore {

    private var cachedProfile: UserProfile?

    public init() {}

    public func save(_ profile: UserProfile) {
        cachedProfile = profile
    }

    public func load() -> UserProfile? {
        return cachedProfile
    }

    public func clear() {
        cachedProfile = nil
    }
}
