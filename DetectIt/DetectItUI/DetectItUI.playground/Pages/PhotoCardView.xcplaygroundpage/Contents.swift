import UIKit
@testable import DetectItUI
import PlaygroundSupport

let screenView = UIView(frame: CGRect(x: 0, y: 0, width: 375, height: 756))
screenView.backgroundColor = .darkGray

let view = PhotoCardView()

view.photo = UIImage.asset(named: "Test")
view.title = "#1 Фотография подозреваемых в убийстве Джона Кеннеди Младшего"

screenView.addSubview(view)
NSLayoutConstraint.activate([
    view.topAnchor.constraint(equalTo: screenView.topAnchor, constant: 20),
    view.leadingAnchor.constraint(greaterThanOrEqualTo: screenView.leadingAnchor, constant: 10),
    view.centerXAnchor.constraint(equalTo: screenView.centerXAnchor),
])

PlaygroundPage.current.liveView = screenView
