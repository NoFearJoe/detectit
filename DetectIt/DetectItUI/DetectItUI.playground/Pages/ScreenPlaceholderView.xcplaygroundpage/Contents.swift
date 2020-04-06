import UIKit
@testable import DetectItUI
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

let screenView = UIView(frame: CGRect(x: 0, y: 0, width: 375, height: 756))
screenView.backgroundColor = .black

let view = ScreenPlaceholderView(isInitiallyHidden: false)
view.backgroundColor = .darkGray

screenView.addSubview(view)
view.pin(to: screenView)

PlaygroundPage.current.liveView = screenView

view.setVisible(true, animated: true)

DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
    view.setVisible(false, animated: true)
}
