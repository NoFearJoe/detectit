import UIKit
@testable import DetectItUI
import PlaygroundSupport

let screenView = UIView(frame: CGRect(x: 0, y: 0, width: 375, height: 756))
screenView.backgroundColor = .darkGray

let view = PaperSheetView()

view.title = "Колорадский маньяк"
view.text = "Далеко на юге штата Колорадо орудовал маньяк, которого в будущем полиция прозвала \"Колорадский маньяк\", потому что он убивал своих жертв картошкой. Полиция так и не смогла поймать его, потому что слишком сильно тупила."

screenView.addSubview(view)
NSLayoutConstraint.activate([
    view.topAnchor.constraint(equalTo: screenView.topAnchor, constant: 20),
    view.leadingAnchor.constraint(equalTo: screenView.leadingAnchor, constant: 10),
    view.centerXAnchor.constraint(equalTo: screenView.centerXAnchor),
])

PlaygroundPage.current.liveView = screenView
