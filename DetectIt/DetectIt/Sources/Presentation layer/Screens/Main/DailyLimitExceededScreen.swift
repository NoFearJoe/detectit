import SwiftUI
import DetectItUI

struct DailyLimitExceededScreen: View {
    let onBuyProVersion: () -> Void
    let onWatchAd: () -> Void
    
    @State private var isProVersionPaywallShown = false
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("daily_limit_exceeded_title".localized)
                .font(.heading1)
                .foregroundColor(.primaryText)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
            
            VSpacer(12)
            
            Text("daily_limit_exceeded_subtitle".localized)
                .font(.text2)
                .foregroundColor(.primaryText)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
            
            Spacer()
            
            ActionButton(
                title: "daily_limit_exceeded_buy_pro_version_title".localized,
                foreground: .darkBackground,
                background: .headlineText
            ) {
                dismiss()
                
                DispatchQueue.main.async {
                    onBuyProVersion()
                }
                
                Analytics.logButtonTap(title: "buy_pro_version", screen: .dailyLimitExceeded)
            }
            
            VSpacer(8)
            
            ActionButton(
                title: "daily_limit_exceeded_watch_ad_title".localized,
                foreground: .primaryText,
                background: .darkBackground
            ) {
                dismiss()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    onWatchAd()
                }
                
                Analytics.logButtonTap(title: "watch_ad", screen: .dailyLimitExceeded)
            }
        }
        .padding()
        .onAppear {
            Analytics.logScreenShow(.dailyLimitExceeded)
        }
    }
}
