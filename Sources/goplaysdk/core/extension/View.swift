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
    
    func hidecompatNavigationTitleWhenLandscape() -> some View {
        self
            .onAppear {
                Task { @MainActor in
                       updatecompatNavigationTitleVisibility()
                }
                NotificationCenter.default.addObserver(
                    forName: UIDevice.orientationDidChangeNotification,
                    object: nil,
                    queue: .main
                ) { _ in
                    Task { @MainActor in
                           updatecompatNavigationTitleVisibility()
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
    private func updatecompatNavigationTitleVisibility() {
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
    
    @MainActor
    @ViewBuilder
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
                        Text("navigate")
//                        EmptyView()
                    }
                } else {
                    EmptyView()
                }
            }
        )
    }
    
//    @ViewBuilder
//    public func compatNavigationTitle(_ title: String) -> some View {
//            if #available(iOS 14.0, *) {
//                self.navigationTitle(title)
//            } else {
//                self.navigationBarTitle(title)
//            }
//        }
    @ViewBuilder
    public func compatNavigationTitle(_ title: String) -> some View {
        if #available(iOS 14.0, *) {
            self
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)   // 👈 FIX
        } else {
            self.navigationBarTitle(title)
        }
    }
    
    @ViewBuilder
    public func compatToolbar<Content: View>(
            @ViewBuilder content: () -> Content
        ) -> some View {
            if #available(iOS 14.0, *) {
                self.toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        content()
                    }
                }
            } else {
                self.navigationBarItems(leading: content())
            }
        }

    // Helper function to return the appropriate view based on the navigation destination
    @MainActor
    private func navigateToDestinationView(destination: NavigationDestination?)
        -> some View
    {
        switch destination {
        case .goIdAuthenView:
            return AnyView(GoIdAuthenView())
        case .goIdAuthenViewV2:
            return AnyView(GoIdAuthenViewV2())
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
    case goIdAuthenViewV2
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
        DispatchQueue.main.async {
            self.destination = destination
            self.path.append(destination)
        }
        
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
