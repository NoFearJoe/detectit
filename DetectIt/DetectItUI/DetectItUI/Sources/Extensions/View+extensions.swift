import SwiftUI

public extension View {
    func bindFrame(
        coordinateSpace: CoordinateSpace = .local,
        _ binding: Binding<CGRect>
    ) -> some View {
        self.overlay(
            GeometryReader { geometry -> Color in
                DispatchQueue.main.async {
                    binding.wrappedValue = geometry.frame(in: coordinateSpace)
                }
                return Color.clear
            }
        )
    }
}

public struct VSpacer: View {
    public let length: CGFloat
    
    public init(_ length: CGFloat) {
        self.length = length
    }
    
    public var body: some View {
        Spacer().frame(height: length)
    }
}
