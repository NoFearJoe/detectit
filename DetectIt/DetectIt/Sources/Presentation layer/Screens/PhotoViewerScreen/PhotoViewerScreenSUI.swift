import SwiftUI
import DetectItUI

struct PhotoViewerScreenSUI: View {
    let image: UIImage
    let title: String?
    
    let namespace: Namespace.ID
    
    let onClose: () -> Void
    
//    @State var scale = 1.0
//    @State var lastScale = 0.0
//    @State var offset: CGSize = .zero
//    @State var lastOffset: CGSize = .zero
//    @State var imageFrame = CGRect.zero
//    @State var backgroundAlpha = CGFloat(1)
    
    var body: some View {
        ZStack {
            VStack {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
//                    .bindFrame($imageFrame)
                    .matchedGeometryEffect(id: "photo", in: namespace)
//                    .gesture(
//                        MagnifyGesture(minimumScaleDelta: 0)
//                            .onChanged(onMagnify(value:))
//                            .onEnded(onMagnifyEnded(value:))
//                            .simultaneously(
//                                with: DragGesture(minimumDistance: 0)
//                                    .onChanged(onDrag(value:))
//                                    .onEnded(onDragEnded(value:))
//                            )
//                    )
//                    .scaleEffect(scale)
//                    .offset(offset)
                
                if let title {
                    Text(title)
                        .font(.text3)
                        .foregroundColor(.secondaryText)
                        .lineLimit(0)
                }
            }
            
            closeButton
        }
        .background(Color.systemBackground.ignoresSafeArea().onTapGesture(perform: onClose))
    }
    
    private var closeButton: some View {
        VStack {
            HStack(alignment: .top) {
                Spacer()
                
                CloseButton {
//                    if scale != 1 {
//                        withAnimation {
//                            scale = 1
//                        } completion: {
//                            onClose()
//                        }
//                    } else {
                        onClose()
//                    }
                }
            }
            .offset(y: -4)
            
            Spacer()
        }
        .padding()
    }
    
//    private func onMagnify(value: MagnifyGesture.Value) {
//        let s = lastScale + value.magnification - (lastScale == 0 ? 0 : 1)
//        
//        withAnimation(.interactiveSpring()) {
//            scale = min(2, max(1, s))
//        }
//    }
//    
//    private func onMagnifyEnded(value: MagnifyGesture.Value) {
//        lastScale = scale
//    }
//    
//    private func onDrag(value: DragGesture.Value) {
//        var newOffset: CGSize = .zero
//
//        newOffset.width = value.translation.width + lastOffset.width
//        newOffset.height = value.translation.height + lastOffset.height
//
////        let maxOffset = max(abs(newOffset.width), abs(newOffset.height))
////        backgroundAlpha = max(0, 1 - (maxOffset / (imageFrame.width * 0.5)))
//
//        withAnimation(.interactiveSpring()) {
//            offset = newOffset
//            backgroundAlpha = CGFloat(sqrt(newOffset.width * newOffset.width + newOffset.height * newOffset.height) / 300.0) * 0.2
//        }
//    }
//    
//    private func onDragEnded(value: DragGesture.Value) {
//        let shouldFinish = max(abs(value.velocity.width), abs(value.velocity.height)) > 300 && value.translation != .zero
//        
//        if shouldFinish {
//            onClose()
//        } else {
//            lastOffset = offset
//            withAnimation(.interactiveSpring()) {
//                backgroundAlpha = 1
//            }
//        }
//    }
}
