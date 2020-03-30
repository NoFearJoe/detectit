import UIKit
@testable import DetectItUI
import PlaygroundSupport

let screenView = UIView(frame: CGRect(x: 0, y: 0, width: 375, height: 756))
screenView.backgroundColor = .darkGray

let delegate = MockEvidenceListViewDelegate()
let view = EvidenceListView(delegate: delegate)

screenView.addSubview(view)
view.pin(to: screenView)

PlaygroundPage.current.liveView = screenView
