import SwiftUI

public struct ActionButton: View {
    public let icon: Image?
    public let title: String
    public let foreground: Color
    public let background: Color
    public let action: () -> Void
    
    public init(
        icon: Image? = nil,
        title: String,
        foreground: Color,
        background: Color,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.title = title
        self.foreground = foreground
        self.background = background
        self.action = action
    }
    
    public var body: some View {
        Button {
            action()
        } label: {
            ZStack {
                background
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                
                Label {
                    Text(title)
                        .font(.text2.weight(.medium))
                        .kerning(0.5)
                        .foregroundColor(foreground)
                } icon: {
                    icon?
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .foregroundColor(foreground)
                }
            }
            .frame(height: 52)
        }
    }
}
