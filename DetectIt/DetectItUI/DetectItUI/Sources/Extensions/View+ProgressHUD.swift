import SwiftUI
import JGProgressHUD_SwiftUI

public enum ProgressHUDState: Equatable {
    case loading
    case success
    case failure(String?)
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading), (.success, .success):
            return true
        case let (.failure(lhsF), .failure(rhsF)):
            return lhsF == rhsF
        default:
            return false
        }
    }
}

public extension View {
    func progressHUD(
        state: Binding<ProgressHUDState?>
    ) -> some View {
        JGProgressHUDPresenter(userInteractionOnHUD: true) {
            modifier(ProgressHUDModifier(
                state: state
            ))
        }
    }
}

private struct ProgressHUDModifier: ViewModifier {
    @Binding var state: ProgressHUDState?
    
    @EnvironmentObject private var coordinator: JGProgressHUDCoordinator
    
    func body(content: Content) -> some View {
        content.onChange(of: state) { state in
            if let state {
                if let hud = coordinator.presentedHUD {
                    updateHUD(hud: hud, state: state)
                } else {
                    coordinator.showHUD {
                        let hud = JGProgressHUD(style: .dark)
                        
                        updateHUD(hud: hud, state: state)
                        
                        return hud
                    } handleExistingHUD: { hud in
                        updateHUD(hud: hud, state: state)
                        
                        return false
                    }
                }
            } else {
                coordinator.presentedHUD?.dismiss(animated: true)
                self.state = nil
            }
        }
    }
    
    private func updateHUD(hud: JGProgressHUD, state: ProgressHUDState) {
        switch state {
        case .loading:
            break
        case .success:
            hud.indicatorView = JGProgressHUDSuccessIndicatorView()
        case let .failure(message):
            hud.indicatorView = JGProgressHUDErrorIndicatorView()
            hud.textLabel.text = message
            
            if message != nil {
                hud.tapOutsideBlock = { [weak hud] _ in
                    hud?.dismiss(animated: true)
                    self.state = nil
                }
                hud.tapOnHUDViewBlock = { [weak hud] _ in
                    hud?.dismiss(animated: true)
                    self.state = nil
                }
            }
        }
    }
}
