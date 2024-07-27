import SwiftUI

public struct ActivityPopover: UIViewControllerRepresentable {

    let items: [Any]
    var activities: [UIActivity] = []
    let didDismiss: UIActivityViewController.CompletionWithItemsHandler
    
    public init(items: [Any], activities: [UIActivity] = [], didDismiss: @escaping UIActivityViewController.CompletionWithItemsHandler) {
        self.items = items
        self.activities = activities
        self.didDismiss = didDismiss
    }

    public func makeUIViewController(context: Context) -> HostVC {
        HostVC(items, activities, didDismiss)
    }

    public func updateUIViewController(_ vc: HostVC, context: Context) {
        vc.prepareActivity()
    }
}

extension ActivityPopover {

    public class HostVC : UIViewController {

        private let items: [Any]
        private let activities: [UIActivity]
        private let didDismiss: UIActivityViewController.CompletionWithItemsHandler
        private var vc: UIActivityViewController? = nil
        private var didPrepare = false
        private var didPresent = false

        init(_ items: [Any],
             _ activities: [UIActivity],
             _ didDismiss: @escaping UIActivityViewController.CompletionWithItemsHandler) {
            self.items = items
            self.activities = activities
            self.didDismiss = didDismiss
            super.init(nibName: nil, bundle: nil)
        }

        required init?(coder: NSCoder) { fatalError() }
    }
}

extension ActivityPopover.HostVC {

    /// Prepare popover in background (can take a second)
    ///
    func prepareActivity() {
        guard didPrepare == false else { return }
        didPrepare = true

        DispatchQueue.global().async { [self] in
            guard self.vc == nil else { return }
            vc = UIActivityViewController(activityItems: items, applicationActivities: activities)
            vc?.completionWithItemsHandler = didDismiss
            DispatchQueue.main.async { [self] in
                self.presentActivity()
            }
        }
    }

    /// Present popover in situ for iPad and iPhone.
    ///
    private func presentActivity() {
        let hasWindow = viewIfLoaded?.window != nil
        guard !didPresent, hasWindow else {
            return tryUntilHasWindow()
        }
        didPresent = true

        if UIDevice.current.userInterfaceIdiom == .pad {
            let pop = vc?.popoverPresentationController
            pop?.sourceView = self.view
            pop?.sourceRect = self.view.frame
        }
        
        if let vc {
            present(vc, animated: true, completion: nil)
        }
    }

    /// SwiftUI may call `updateUIViewController` before moving this controller into a window.
    /// In this situation, presenting the `UIActivityViewController` will not work, `didDismiss`
    /// will not be called, and this export will appear to hang.
    ///
    /// This method polls for when presentation is safe.
    ///
    private func tryUntilHasWindow() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.presentActivity()
        }
    }
}
