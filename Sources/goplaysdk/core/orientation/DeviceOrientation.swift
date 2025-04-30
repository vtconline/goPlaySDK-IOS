import SwiftUI
import Combine
@MainActor
class DeviceOrientation: ObservableObject {
    static let shared = DeviceOrientation() // Singleton instance
    
    @Published var isLandscape: Bool = false
    
    private var cancellable: AnyCancellable?
    
    private init() {
        // Initial orientation check
        self.isLandscape = UIScreen.main.bounds.width > UIScreen.main.bounds.height
        
        // Listen for orientation changes
        self.cancellable = NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
            .sink { _ in
                self.updateOrientation()
            }
    }
    
    func updateOrientation() {
        // Update the orientation status based on the screen size
        self.isLandscape = UIDevice.current.orientation.isLandscape//UIScreen.main.bounds.width > UIScreen.main.bounds.height
        //print("updateOrientation isLandscape= \(self.isLandscape)")
    }
}
