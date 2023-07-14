import SwiftUI
import DetectItUI

struct MainScreenPictureView<A: Equatable>: View {
    let file: String?
    let size: CGSize
    let blurred: Bool
    let animationValue: A
        
    var body: some View {
        ZStack {
            if let file {
                Image(uiImage: UIImage(contentsOfFile: file) ?? UIImage())
                    .resizable()
                    .antialiased(true)
                    .aspectRatio(contentMode: .fill)
                    .blur(radius: blurred ? 3 : 0)
                    .frame(width: size.width, height: size.height)
                    .clipped()
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .animation(.default, value: animationValue)
            }
            
            LinearGradient(
                colors: [.clear, .black.opacity(0.35), .black],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(width: size.width, height: size.height)
            .ignoresSafeArea()
        }
    }
}
