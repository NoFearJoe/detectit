import UIKit
@testable import DetectItUI
import PlaygroundSupport

let screenView = UIView(frame: CGRect(x: 0, y: 0, width: 375, height: 756))
screenView.backgroundColor = .darkGray

let photoCardView = PhotoCardView()

photoCardView.photo = UIImage.asset(named: "Test")
photoCardView.title = "#1 Фотография подозреваемых в убийстве Джона Кеннеди Младшего"

screenView.addSubview(photoCardView)
NSLayoutConstraint.activate([
    photoCardView.topAnchor.constraint(equalTo: screenView.topAnchor, constant: 20),
    photoCardView.leadingAnchor.constraint(greaterThanOrEqualTo: screenView.leadingAnchor, constant: 10),
    photoCardView.centerXAnchor.constraint(equalTo: screenView.centerXAnchor),
])

PlaygroundPage.current.liveView = screenView
