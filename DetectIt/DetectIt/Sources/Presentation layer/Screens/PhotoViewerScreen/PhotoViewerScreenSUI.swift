import SwiftUI
import DetectItUI

struct PhotoViewerScreenSUI: View {
    let image: UIImage
    let title: String?
    
    let namespace: Namespace.ID
    
    let onClose: () -> Void
    
    var body: some View {
        ZStack {
            VStack {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .matchedGeometryEffect(id: "photo", in: namespace)
                
                if let title {
                    Text(title)
                        .font(.text3)
                        .foregroundColor(.secondaryText)
                        .lineLimit(0)
                }
            }
            
            closeButton
        }
        .background(Color.systemBackground.ignoresSafeArea())
    }
    
    private var closeButton: some View {
        VStack {
            HStack {
                Spacer()
                
                CloseButton {
                    onClose()
                }
            }
            
            Spacer()
        }
        .padding()
    }
}
