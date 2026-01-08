import SwiftUI

#if canImport(UIKit)
    import UIKit
#endif
extension View {
    
    // Hide keyboard khi cần (SwiftUI + UIKit bridge)
    public func hideKeyboard() {
        #if canImport(UIKit)
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil,
                from: nil,
                for: nil
            )
        #endif
    }
    // MARK: - Tap + Scroll đều ẩn keyboard
    public func dismissKeyboardOnInteraction() -> some View {
        self
            // Tap background
            .onTapGesture {
                hideKeyboard()
            }
            // Scroll / Drag
            .simultaneousGesture(
                DragGesture(minimumDistance: 1)
                    .onChanged { _ in
                        hideKeyboard()
                    }
            )
    }
    
    func hideNavigationTitleWhenLandscape() -> some View {
        self
            .onAppear {
                updateNavigationTitleVisibility()
                NotificationCenter.default.addObserver(
                    forName: UIDevice.orientationDidChangeNotification,
                    object: nil,
                    queue: .main
                ) { _ in
                    Task { @MainActor in
                                            updateNavigationTitleVisibility()
                    }
                }
            }
            .onDisappear {
                NotificationCenter.default.removeObserver(
                    self,
                    name: UIDevice.orientationDidChangeNotification,
                    object: nil
                )
            }
    }
    @MainActor
    private func updateNavigationTitleVisibility() {
        #if canImport(UIKit)
        let orientation = UIDevice.current.orientation

        let isLandscape = orientation == .landscapeLeft || orientation == .landscapeRight

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()

        appearance.titleTextAttributes = [
            .foregroundColor: isLandscape ? UIColor.clear : UIColor.label
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: isLandscape ? UIColor.clear : UIColor.label
        ]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        #endif
    }
    // Function to reset navigation when app goes inactive
    public func resetNavigationWhenInActive(
        navigationManager: NavigationManager,
        scenePhase: ScenePhase
    ) -> some View {
        self.onChange(of: scenePhase) { phase in
            print("navigationManager.resetNavigation phase = \(phase) ")
            if phase == .inactive {
                print("navigationManager.resetNavigation call ")
                navigationManager.resetNavigation()
            }
        }
    }

    public func navigateToDestination(navigationManager: NavigationManager)
        -> some View
    {
        self.background(
            Group {
                if let destination = navigationManager.destination {
                    NavigationLink(
                        destination: navigateToDestinationView(
                            destination: destination
                        ),
                        isActive: Binding(
                            get: { navigationManager.destination != nil },
                            set: { isActive in
                                if !isActive {
                                    navigationManager.resetNavigation()
                                }
                            }
                        )
                    ) {
                        EmptyView()
                    }
                } else {
                    EmptyView()
                }
            }
        )
    }

    // Helper function to return the appropriate view based on the navigation destination
    private func navigateToDestinationView(destination: NavigationDestination?)
        -> some View
    {
        switch destination {
        case .goIdAuthenView:
            return AnyView(GoIdAuthenView())
        case .userInfoView:
            return AnyView(RegisterView())
        case .updateGuestInfoView:
            return AnyView(GuestLoginUpdateProfileView())
        case .none:
            return AnyView(EmptyView())  // No navigation
        }
    }
}
// Move NavigationDestination outside of NavigationManager
public enum NavigationDestination {
    case goIdAuthenView
    case userInfoView
    case updateGuestInfoView
}
@MainActor
public class NavigationManager: ObservableObject {
    // Track the current destination
    @Published public var destination: NavigationDestination?
    @Published public var path: [NavigationDestination] = []
    public init() {}  // <-- ADD THIS: ensure public this init for use in other app

    // Navigation functions to set the destination
    public func navigate(to destination: NavigationDestination) {

        self.destination = destination
        path.append(destination)
    }
    public func popToRoot() {
        path.removeAll()
        self.destination = nil  // Set destination to nil to reset navigation state
    }

    func popBackTo(_ destination: NavigationDestination) {
        while path.last != destination {
            path.removeLast()
        }
    }

    func popBackUntil(where shouldStop: (NavigationDestination) -> Bool) {
        while let last = path.last, !shouldStop(last) {
            path.removeLast()
        }
    }

    public func resetNavigation() {
        self.destination = nil
    }
}
