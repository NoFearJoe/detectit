import SwiftUI
import StoreKit
import DetectItUI
import DetectItCore
import JGProgressHUD

struct FullVersionPurchaseScreen: View {
    @StateObject private var model = FullVersionPurchaseModel()
    
    @State private var hudState: ProgressHUDState?
    
    var body: some View {
        Group {
            if model.isLoaded {
                VStack(alignment: .leading, spacing: 0) {
                    titleView
                    VSpacer(40)
                    subtitleView
                    
                    Spacer()
                    
                    buyButton
                    restoreButton
                }
                .animation(.default, value: model.isLoaded)
            } else {
                Color.clear
            }
        }
        .padding()
        .padding(.top, 20)
        .background(background)
        .progressHUD(state: $hudState)
        .preferredColorScheme(.dark)
        .onAppear {
            Analytics.logScreenShow(.fullVersionPurchase)
        }
        .task {
            if !model.checkIfLoaded() {
                hudState = .loading
            }
            await model.load()
            hudState = nil
        }
    }
    
    private var titleView: some View {
        Text("pro_status_title".localized)
            .font(.heading0)
            .foregroundColor(.primaryText)
            .lineLimit(nil)
            .multilineTextAlignment(.leading)
    }
    
    private var subtitleView: some View {
        Text("pro_status_subtitle".localized)
            .font(.text1)
            .foregroundColor(.primaryText)
            .lineLimit(nil)
            .multilineTextAlignment(.leading)
            .lineSpacing(2)
    }
    
    private var buyButton: some View {
        ActionButton(
            title: "pro_status_buy_button_title".localized(model.price ?? "0"),
            foreground: .darkBackground,
            background: .headlineText
        ) {
            buy()
        }
    }
    
    private var restoreButton: some View {
        ActionButton(
            title: "pro_status_restore".localized,
            foreground: .secondaryText,
            background: .clear
        ) {
            restore()
        }
    }
    
    private var background: some View {
        Image("main_bg")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .overlay {
                LinearGradient(
                    colors: [.darkBackground, .darkBackground.opacity(0.85), .darkBackground],
                    startPoint: .bottom,
                    endPoint: .top
                )
            }
            .ignoresSafeArea()
    }
    
    private func buy() {
        Analytics.logButtonTap(title: "buy_pro_version", screen: .fullVersionPurchase)
        
        _Concurrency.Task {
            hudState = .loading
            
            do {
                try await model.buy()
                hudState = .success
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    hudState = nil
                }
                
                logPurchase(product: .pro)
            } catch {
                hudState = .failure("error_hud_title".localized)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    hudState = nil
                }
            }
        }
    }
    
    private func restore() {
        Analytics.logButtonTap(title: "restore_purchases", screen: .fullVersionPurchase)
        
        _Concurrency.Task {
            hudState = .loading
            
            if await model.restore() {
                hudState = .success
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    hudState = nil
                }
            } else {
                hudState = .failure("error_hud_title".localized)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    hudState = nil
                }
            }
        }
    }
    
    private func logPurchase(product: FullVersionManager.Product) {
        guard let price = FullVersionManager.priceValue(for: product) else { return }
        
        Analytics.logRevenue(price: price, productID: product.id)
    }
}

final class FullVersionPurchaseModel: ObservableObject {
    @Published var isLoaded = false
    @Published var price: String?
    
    func checkIfLoaded() -> Bool {
        FullVersionManager.price(for: .pro) != nil
    }
    
    func load() async {
        await withCheckedContinuation { continuation in
            FullVersionManager.subscribeToProductInfoLoading(self) { [weak self] in
                self?.isLoaded = true
                self?.price = FullVersionManager.price(for: .pro)
                continuation.resume()
            }
            FullVersionManager.obtainProductInfo()
        }
    }
    
    func buy() async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            FullVersionManager.purchase(product: .pro) { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
    
    func restore() async -> Bool {
        await withCheckedContinuation { continuation in
            FullVersionManager.restorePurchases { success in
                continuation.resume(returning: success)
            }
        }
    }
}
