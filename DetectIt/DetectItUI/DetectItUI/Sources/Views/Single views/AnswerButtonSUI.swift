import SwiftUI

public struct AnswerButtonSUI: View {
    let title: String
    @Binding var isFilled: Bool
    @Binding var isErrorOccured: Bool
    let action: () -> Void
    
    public init(title: String, isFilled: Binding<Bool>, isErrorOccured: Binding<Bool>, action: @escaping () -> Void) {
        self.title = title
        self._isFilled = isFilled
        self._isErrorOccured = isErrorOccured
        self.action = action
    }
    
    @State private var fillPercent: CGFloat = 0
    @State private var fillingTimer: Timer?
    @State private var shake = ShakeEffect.Trigger()
    
    @Environment(\.isEnabled) private var isEnabled
    
    private let fillFeedback = UIImpactFeedbackGenerator(style: .heavy)
    private let errorFeedback = UINotificationFeedbackGenerator()
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Group {
                    isEnabled ? Color.gray : Color.gray.opacity(0.35)
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Color.yellow
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .offset(x: geometry.size.width * CGFloat(fillPercent) - geometry.size.width)
                
                HStack {
                    Spacer()
                    Text(title)
                        .font(.text2)
                        .foregroundStyle(.black)
                        .lineLimit(nil)
                        .multilineTextAlignment(.center)
                        .kerning(0.5)
                    Spacer()
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        guard !isFilled else { return }
                        
                        let frame = geometry.frame(in: .local)
                        
                        if frame.contains(value.location) {
                            startFilling()
                        } else {
                            cancelFilling()
                        }
                    }
                    .onEnded { value in
                        if !isFilled {
                            cancelFilling()
                        } else if fillingTimer != nil {
                            let frame = geometry.frame(in: .local)
                            
                            if frame.contains(value.location) {
                                endFilling()
                                action()
                            } else {
                                cancelFilling()
                            }
                        }
                    }
            )
        }
        .frame(height: 56)
        .modifier(ShakeEffect(trigger: shake))
        .onChange(of: isFilled) { filled in
            fillPercent = filled ? 1 : 0
        }
        .onChange(of: isErrorOccured) { error in
            guard error else { return }
            
            fillFeedback.impactOccurred()
            
            if #available(iOS 17.0, *) {
                withAnimation(.interpolatingSpring(mass: 0.5, stiffness: 500, damping: 7)) {
                    shake.fire()
                } completion: {
                    cancelFilling()
                }
            } else {
                withAnimation(.interpolatingSpring(mass: 0.5, stiffness: 500, damping: 7)) {
                    shake.fire()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    cancelFilling()
                }
            }
            isErrorOccured = false
        }
    }
    
    private func startFilling() {
        guard fillingTimer == nil else { return }
        
        withAnimation(.easeOut(duration: 0.75)) {
            fillPercent = 1
        }
        fillingTimer = Timer.scheduledTimer(
            withTimeInterval: 0.75,
            repeats: false
        ) { _ in
            isFilled = true
            errorFeedback.notificationOccurred(.error)
        }
    }
    
    private func endFilling() {
        fillingTimer?.invalidate()
        fillingTimer = nil
    }
    
    private func cancelFilling() {
        withAnimation(.easeOut(duration: 0.25)) {
            fillPercent = 0
        }
        fillingTimer?.invalidate()
        fillingTimer = nil
        isFilled = false
    }
}

private struct ButtonPreview: View {
    @State var isFilled = false
    @State var isErrorOccured = false
    
    var body: some View {
        AnswerButtonSUI(title: "Title", isFilled: $isFilled, isErrorOccured: $isErrorOccured, action: { print("action") })
            .padding()
        
        Button {
            isFilled.toggle()
        } label: {
            Text("toggle")
        }
        
        Button {
            isErrorOccured = true
        } label: {
            Text("error")
        }
    }
}

#Preview {
    ButtonPreview()
}

// MARK: - Reusable

struct ShakeEffect: GeometryEffect {
    struct Trigger: Equatable {
        var animatableValue = CGFloat(0)
        
        mutating func fire() {
            animatableValue = animatableValue == 0 ? 1 : 0
        }
    }
    
    var trigger: Trigger
    
    var animatableData: CGFloat {
        get { trigger.animatableValue }
        set { trigger.animatableValue = newValue }
    }
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(
            CGAffineTransform(
                translationX: -sin(trigger.animatableValue * .pi) * 5,
                y: 0
            )
        )
    }
}
