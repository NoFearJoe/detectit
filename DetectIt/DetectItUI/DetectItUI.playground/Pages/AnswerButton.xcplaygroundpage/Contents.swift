import UIKit
@testable import DetectItUI
import PlaygroundSupport

let screenView = UIView(frame: CGRect(x: 0, y: 0, width: 375, height: 756))
screenView.backgroundColor = .black

let view = AnswerButton()

screenView.addSubview(view)
NSLayoutConstraint.activate([
    view.heightAnchor.constraint(equalToConstant: 52),
    view.topAnchor.constraint(equalTo: screenView.topAnchor, constant: 20),
    view.leadingAnchor.constraint(equalTo: screenView.leadingAnchor, constant: 10),
    view.centerXAnchor.constraint(equalTo: screenView.centerXAnchor),
])

PlaygroundPage.current.liveView = screenView
