import SwiftUI
import Nuke

struct ZoomableImageViewer: UIViewRepresentable {
    let url: URL
    @Binding var isPresented: Bool
    
    func makeUIView(context: Context) -> UIView {
        let container = UIScrollView(frame: UIScreen.main.bounds)
        
        let scrollView = UIScrollView(frame: UIScreen.main.bounds)
        scrollView.delegate = context.coordinator
        scrollView.maximumZoomScale = 5.0
        scrollView.minimumZoomScale = 1.0
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceVertical = false
        scrollView.alwaysBounceHorizontal = false
        container.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: container.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])
        
        // UIImageView
        let imageView = UIImageView(frame: UIScreen.main.bounds)
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(imageView)
        context.coordinator.imageView = imageView
        
        // Pin imageView edges to scrollView content
        let widthConstraint = imageView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        let heightConstraint = imageView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        let centerX = imageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor)
        let centerY = imageView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor)
        NSLayoutConstraint.activate([widthConstraint, heightConstraint, centerX, centerY])
        
        context.coordinator.widthConstraint = widthConstraint
        context.coordinator.heightConstraint = heightConstraint
        context.coordinator.centerXConstraint = centerX
        context.coordinator.centerYConstraint = centerY
        
        // Load image with Nuke
        Nuke.loadImage(with: url, options: .init(transition: .fadeIn(duration: 0.25)), into: imageView)
        
        // Close button
        let closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(systemName: "xmark")?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.backgroundColor = UIColor.gray.withAlphaComponent(0.7)
        closeButton.layer.cornerRadius = 18 // half of width/height
        closeButton.clipsToBounds = true
        closeButton.addTarget(context.coordinator, action: #selector(Coordinator.closeTapped), for: .touchUpInside)
        container.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: container.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            closeButton.widthAnchor.constraint(equalToConstant: 36),
            closeButton.heightAnchor.constraint(equalToConstant: 36)
        ])
        
        // Double-tap to zoom
        let doubleTap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        imageView.addGestureRecognizer(doubleTap)
        
        // Swipe down to dismiss
        let swipeDown = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleSwipe(_:)))
        scrollView.addGestureRecognizer(swipeDown)
        
        // One-finger drag even at 1x zoom
        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan(_:)))
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 1
        imageView.addGestureRecognizer(panGesture)
        
        return container
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.updateZoom()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(isPresented: $isPresented)
    }
    
    // MARK: - Coordinator
    class Coordinator: NSObject, UIScrollViewDelegate, UIGestureRecognizerDelegate {
        var imageView: UIImageView?
        @Binding var isPresented: Bool
        var widthConstraint: NSLayoutConstraint?
        var heightConstraint: NSLayoutConstraint?
        var centerXConstraint: NSLayoutConstraint?
        var centerYConstraint: NSLayoutConstraint?
        
        init(isPresented: Binding<Bool>) {
            _isPresented = isPresented
        }
        
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return imageView
        }
        
        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            guard let imageView = imageView else { return }
            
            let offsetX = max((scrollView.bounds.width - imageView.frame.width) / 2, 0)
            let offsetY = max((scrollView.bounds.height - imageView.frame.height) / 2, 0)
            centerXConstraint?.constant = offsetX
            centerYConstraint?.constant = offsetY
            imageView.superview?.layoutIfNeeded()
        }
        
        func updateZoom() {
            scrollViewDidZoom(imageView?.superview as! UIScrollView)
        }
        
        @objc func handleDoubleTap(_ sender: UITapGestureRecognizer) {
            guard let scrollView = sender.view?.superview as? UIScrollView else { return }
            if scrollView.zoomScale > 1 {
                scrollView.setZoomScale(1, animated: true)
            } else {
                let point = sender.location(in: sender.view)
                let zoomRect = zoomRectForScale(scale: scrollView.maximumZoomScale, center: point, scrollView: scrollView)
                scrollView.zoom(to: zoomRect, animated: true)
            }
        }
        
        private func zoomRectForScale(scale: CGFloat, center: CGPoint, scrollView: UIScrollView) -> CGRect {
            var zoomRect = CGRect.zero
            zoomRect.size.height = scrollView.frame.size.height / scale
            zoomRect.size.width  = scrollView.frame.size.width  / scale
            zoomRect.origin.x = center.x - (zoomRect.size.width / 2.0)
            zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0)
            return zoomRect
        }
        
        @objc func handleSwipe(_ sender: UIPanGestureRecognizer) {
            guard let scrollView = sender.view as? UIScrollView else { return }
            if scrollView.zoomScale > 1 { return } // only allow swipe-to-dismiss when not zoomed
            let translation = sender.translation(in: sender.view)
            let velocity = sender.velocity(in: sender.view)
            if sender.state == .ended {
                if translation.y > 150 || velocity.y > 500 {
                    isPresented = false
                }
            }
        }
        
        @objc func handlePan(_ sender: UIPanGestureRecognizer) {
            guard let imageView = imageView else { return }
            let translation = sender.translation(in: imageView.superview)
            if sender.state == .changed || sender.state == .ended {
                imageView.center = CGPoint(
                    x: imageView.center.x + translation.x,
                    y: imageView.center.y + translation.y
                )
                sender.setTranslation(.zero, in: imageView.superview)
            }
        }
        
        // Allow simultaneous recognition for pan + swipe
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
        }
        
        @objc func closeTapped() {
            isPresented = false
        }
    }
}
