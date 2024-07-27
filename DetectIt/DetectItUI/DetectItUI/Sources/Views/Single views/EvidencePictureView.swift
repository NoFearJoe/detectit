import SwiftUI

public struct EvidencePictureView: View {
    let image: UIImage
    
    public init(image: UIImage) {
        self.image = image
    }
    
    public var body: some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(image.size.width / image.size.height, contentMode: .fit)
    }
}
