import UIKit
@testable import DetectItUI
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

let screenView = UIView(frame: CGRect(x: 0, y: 0, width: 375, height: 756))
screenView.backgroundColor = .black

let view = RatingView(maxRating: 5, size: .big)
view.backgroundColor = .white
view.tintColor = .yellow
view.isEnabled = true

screenView.addSubview(view)
view.translatesAutoresizingMaskIntoConstraints = false
NSLayoutConstraint.activate([
    view.heightAnchor.constraint(equalToConstant: 40),
    view.centerYAnchor.constraint(equalTo: screenView.centerYAnchor),
    view.centerXAnchor.constraint(equalTo: screenView.centerXAnchor)
])

PlaygroundPage.current.liveView = screenView

view.rating = 2.3
