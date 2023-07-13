import SwiftUI

public extension View {
    func onFirstAppear(perform action: (() -> Void)?) -> some View {
        modifier(FirstAppearModifier(perform: action))
    }
    
    func singleTask(perform task: (() async -> Void)?) -> some View {
        modifier(FirstTaskModifier(task))
    }
}

// MARK: - Internal

struct FirstAppearModifier: ViewModifier {
    
    @State private var didAppear = false
    private var action: (() -> Void)?
    
    init(perform action: (() -> Void)?) {
        self.action = action
    }
    
    func body(content: Content) -> some View {
        content.onAppear {
            if !didAppear {
                didAppear = true
                action?()
            }
        }
    }
}

struct FirstTaskModifier: ViewModifier {
    
    @State private var didAppear = false
    private var task: (() async -> Void)?
    
    init(_ task: (() async -> Void)?) {
        self.task = task
    }
    
    func body(content: Content) -> some View {
        content
            .task {
                if !didAppear {
                    didAppear = true
                    await task?()
                }
            }
    }
}
