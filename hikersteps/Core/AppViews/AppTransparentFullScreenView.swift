import SwiftUI

final class TransparentHostingController<Content: View>: UIHostingController<Content> {
    override init(rootView: Content) {
        super.init(rootView: rootView)
        modalPresentationStyle = .overFullScreen
        view.backgroundColor = .clear        // <- important
        view.isOpaque = false                // <- important
        modalPresentationCapturesStatusBarAppearance = true
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct TransparentFullScreenCover<Content: View>: UIViewControllerRepresentable {
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }
    
    func makeUIViewController(context: Context) -> UIViewController {
        TransparentHostingController(rootView: content)
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
