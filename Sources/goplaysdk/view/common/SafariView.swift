

import SwiftUI
import SafariServices

struct SafariView: UIViewControllerRepresentable {
    let url: URL

    init(url: URL) {
        self.url = url
    }

    func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        // no updates needed
    }
}

struct ContentView: View {
    @State private var isShowingSafari = false
    private let websiteURL = URL(string: "https://example.com")!

    var body: some View {
        Button("Open Website") {
            isShowingSafari = true
        }
        .sheet(isPresented: $isShowingSafari) {
            SafariView(url: websiteURL)
        }
    }
}
