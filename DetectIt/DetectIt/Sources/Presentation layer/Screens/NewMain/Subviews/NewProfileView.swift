import SwiftUI
import DetectItUI
import DetectItCore

struct NewProfileView: View {
    let accuracy: Double
    let onTap: () -> Void
    
    var body: some View {
//        Button {
//            onTap()
//        } label: {
            HStack(spacing: 0) {
//                VStack(alignment: .leading, spacing: 0) {
//                    titleView
//                    VSpacer(8)
//                    scoreView
//                }
                
                Spacer()
                
                settingsButton
            }
//        }
    }
    
    private var titleView: some View {
        Text("main_screen_profile_title".localized)
            .font(.heading2)
            .foregroundColor(.primaryText)
            .lineLimit(2)
            .multilineTextAlignment(.leading)
    }
    
    private var scoreView: some View {
        Text("main_screen_accuracy_title".localized(Int(accuracy * 100)))
            .font(.heading2)
            .foregroundColor(.headlineText)
//            .font(.score2)
//            .foregroundColor(.headlineText)
            .lineLimit(1)
    }
    
    private var settingsButton: some View {
        Button {
            onTap()
        } label: {
            Image(systemName: "gearshape.fill")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(.primaryText)
                .shadow(radius: 14)
        }
    }
}
