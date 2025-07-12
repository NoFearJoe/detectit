import SwiftUI

public struct ScreenHUDView: View {
    @Binding var isNotesPresented: Bool
    @Binding var isSharingPresented: Bool
    let onClose: () -> Void
    
    public init(isNotesPresented: Binding<Bool>, isSharingPresented: Binding<Bool>, onClose: @escaping () -> Void) {
        self._isNotesPresented = isNotesPresented
        self._isSharingPresented = isSharingPresented
        self.onClose = onClose
    }
    
    public var body: some View {
        VStack {
            HStack(alignment: .center) {
                Button {
                    isNotesPresented = true
                } label: {
                    Image("notes", bundle: .ui)
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(.yellow)
                }
                Button {
                    isSharingPresented = true
                } label: {
                    Image("share", bundle: .ui)
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(.yellow)
                }
                
                Spacer()
                
                CloseButton {
                    onClose()
                }
            }
            .frame(height: 48)
            .padding(.horizontal)
            
            Spacer()
        }
        .background(alignment: .top) {
            VStack(spacing: 0) {
                Color.systemBackground
                    .ignoresSafeArea(edges: .top)
                    .frame(height: 1)
                
                LinearGradient(
                    colors: [.systemBackground, .systemBackground.opacity(0)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 56)
            }
        }
        .background(alignment: .bottom) {
            LinearGradient(
                colors: [.systemBackground, .systemBackground.opacity(0)],
                startPoint: .bottom,
                endPoint: .top
            )
            .ignoresSafeArea(edges: .bottom)
            .frame(height: 1)
        }
    }
}

public struct CloseButton: View {
    let onClose: () -> Void
    
    public init(onClose: @escaping () -> Void) {
        self.onClose = onClose
    }
    
    public var body: some View {
        Button(action: onClose) {
            Color.gray
                .frame(width: 24, height: 24)
                .clipShape(Circle())
                .contentShape(Circle())
                .overlay {
                    Image("close", bundle: .ui)
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.black)
                }
        }
    }
}
