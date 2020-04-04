import UIKit
@testable import DetectItUI
import PlaygroundSupport

let screenView = UIView(frame: CGRect(x: 0, y: 0, width: 375, height: 756))
screenView.backgroundColor = .black

let view = TasksBundleCell()
view.contentView.translatesAutoresizingMaskIntoConstraints = false

view.configure(
    model: .init(
        backgroundImage: UIImage.asset(named: "Test")!.applyingOldPhotoFilter(),
        title: "Игра #1",
        description: "Скандалы, интриги, расследования",
        playState: .playable
    )
)

screenView.addSubview(view.contentView)
NSLayoutConstraint.activate([
    view.contentView.topAnchor.constraint(equalTo: screenView.topAnchor, constant: 20),
    view.contentView.leadingAnchor.constraint(equalTo: screenView.leadingAnchor, constant: 10),
    view.contentView.trailingAnchor.constraint(equalTo: screenView.trailingAnchor, constant: -10),
    view.contentView.heightAnchor.constraint(equalToConstant: 512)
])

PlaygroundPage.current.liveView = screenView
