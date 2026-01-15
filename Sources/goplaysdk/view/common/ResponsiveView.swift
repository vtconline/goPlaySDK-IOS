import SwiftUI

// Custom view that takes two different views as arguments for portrait and landscape
struct ResponsiveView<PortraitContent: View, LandscapeContent: View>: View {
    @State private var isLandscape: Bool = false // Track the orientation
    
    let portraitView: PortraitContent
    let landscapeView: LandscapeContent

    // Initializer to accept the views for portrait and landscape
    init(portraitView: PortraitContent, landscapeView: LandscapeContent) {
        self.portraitView = portraitView
        self.landscapeView = landscapeView
    }

    var body: some View {
        GeometryReader { geometry in
            VStack {
                // Conditional rendering based on the orientation
                if isLandscape {
                    landscapeView // Display landscape content
                } else {
                    portraitView // Display portrait content
                }
            }
            .onAppear {
                // Initial orientation check when the view appears
                self.isLandscape = DeviceOrientation.shared.isLandscape
                print("isLandscape \(DeviceOrientation.shared.isLandscape)")
            }
            .onChangeCompat(of: geometry.size) { newSize in
                // Detect orientation changes when size changes
                self.isLandscape = DeviceOrientation.shared.isLandscape
                print("onChange geometry.size isLandscape \(DeviceOrientation.shared.isLandscape)")
            }
            .padding(.horizontal,0)
            .padding(.vertical, 0)
            .frame(maxWidth: .infinity, alignment: .center)
            
        }
        .edgesIgnoringSafeArea(.all) // Optional: To make the view fill the screen
    }
}

