import UIKit
import DetectItUI
import DetectItCore

final class SplashScreen: Screen {
    
    private let imageView = UIImageView(image: UIImage(named: "LaunchIcon"))
    
    override func prepare() {
        super.prepare()
        
        view.addSubview(imageView)
        
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 96),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        AuthService.shared.startAuth()
    }
    
}
