import SwiftUI
import DetectItUI

struct MainScreenPictureView: View {
    let file: String?
    let size: CGSize
    let blurred: Bool
        
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

//        Image(uiImage: UIImage(contentsOfFile: file) ?? UIImage())
//            .resizable()
//            .antialiased(true)
//            .aspectRatio(contentMode: .fit)
////            .blur(radius: 4)
////            .overlay {
////                Rectangle()
////                    .fill(.ultraThinMaterial)
////                    .opacity(0.99)
////            }
//            .clipped()
//            .padding(6)
//            .border(Color(red: 0.9, green: 0.88, blue: 0.82), width: 8)
//            .overlay {
//                Image("pin")
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .rotationEffect(.degrees(-90), anchor: .center)
//                    .frame(width: 32, height: 32)
//                    .position(x: 8, y: 8)
//
//                Image("pin")
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .frame(width: 32, height: 32)
////                    .rotationEffect(.degrees(90))
//                    .position(x: size.width * 0.85 - 8, y: 6)
//            }
//            .frame(width: size.width * 0.85, height: size.height * 0.85)
//            .rotationEffect(.degrees(rotation))
//            .onAppear {
//                rotation = .random(in: -4...4)
//            }
//            .id(file)
//            .transition(
//                .asymmetric(
//                    insertion: .modifier(
//                        active: Transition(offset: size.width * 1.25),
//                        identity: Transition(offset: 0)
//                    ),
//                    removal: .modifier(
//                        active: Transition(offset: -size.width * 1.25),
//                        identity: Transition(offset: 0)
//                    )
//                )
//            )
