import SwiftUI
import Combine
import YandexMobileAds
import DetectItCore

final class MainAdsModel: NSObject, ObservableObject {
    @Published var currentTaskIndex = 0
    @Published var isDailyTaskLimitExceeded = false
    
    @Published private var adState = AdState.notLoaded
    @Published private var rewarded = false
    
    private var interstitialAd = YMAInterstitialAd(adUnitID: interstitialAdID)
    private var rewardedAd = YMARewardedAd(adUnitID: rewardedAdID)
    
    private var cancellables = Set<AnyCancellable>()
    
    #if DEBUG
    private static let interstitialAdID = "demo-interstitial-yandex"
    #else
    private static let interstitialAdID = "R-M-2491983-1"
    #endif
    
    #if DEBUG
    private static let rewardedAdID = "demo-rewarded-yandex"
    #else
    private static let rewardedAdID = "R-M-2496182-1"
    #endif
    
    func loadAds() {
        switch currentAdType {
        case .interstitial:
            adState = .loading
            interstitialAd = YMAInterstitialAd(adUnitID: Self.interstitialAdID)
            interstitialAd.delegate = self
            interstitialAd.load()
        case .rewarded:
            adState = .loading
            rewardedAd = YMARewardedAd(adUnitID: Self.rewardedAdID)
            rewardedAd.delegate = self
            rewardedAd.load()
        default:
            break
        }
    }
    
    var needToShowAd: Bool {
        switch currentAdType {
        case .interstitial:
            return !interstitialAd.hasBeenPresented
        case .rewarded:
            return !rewardedAd.hasBeenPresented
        default:
            return false
        }
    }
    
    enum PresentationState {
        case loading
        case presented
        case completed(rewarded: Bool)
        case failed
    }
    
    func present(
        allowFailure: Bool,
        onStateChange: @escaping (PresentationState) -> Void
    ) {
        present(
            state: adState,
            allowFailure: allowFailure,
            attempt: 0,
            onStateChange: onStateChange
        )
    }
    
    private func present(
        state: AdState,
        allowFailure: Bool,
        attempt: Int,
        onStateChange: @escaping (PresentationState) -> Void
    ) {
        switch state {
        case .notLoaded:
            break
        case .loading:
            onStateChange(.loading)
            
            $adState
                .removeDuplicates()
                .filter { $0 != .loading && $0 != .notLoaded }
                .sink { [weak self] state in
                    self?.present(
                        state: state,
                        allowFailure: allowFailure,
                        attempt: attempt,
                        onStateChange: onStateChange
                    )
                }
                .store(in: &cancellables)
        case .loaded:
            onStateChange(.presented)
            cancellables.removeAll()
            
            let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            let vc = scene?.windows.first?.rootViewController
            vc.map {
                presentAd(from: $0) { [weak self] in
                    guard let self else { return }
                    
                    onStateChange(.completed(rewarded: self.rewarded))
                    
                    self.rewarded = false
                }
            }
        case .failedToLoad, .failedToPresent:
            cancellables.removeAll()
            
            if allowFailure {
                onStateChange(.completed(rewarded: false))
            } else if attempt < 3 {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(attempt + 1)) {
                    self.loadAds()
                    self.present(
                        state: self.adState,
                        allowFailure: allowFailure,
                        attempt: attempt + 1,
                        onStateChange: onStateChange
                    )
                }
            } else {
                onStateChange(.failed)
            }
        }
    }
    
    private func presentAd(from vc: UIViewController, completion: @escaping () -> Void) {
        switch currentAdType {
        case .interstitial:
            interstitialAd.present(from: vc) { [weak self] in
                completion()
                
                self?.adState = .notLoaded
            }
        case .rewarded:
            rewardedAd.present(from: vc) { [weak self] in
                completion()
                
                self?.rewarded = false
                self?.adState = .notLoaded
            }
        default:
            break
        }
    }
}

extension MainAdsModel {
    enum AdState {
        case notLoaded
        case loading
        case loaded
        case failedToLoad
        case failedToPresent
    }
}
    
private extension MainAdsModel {
    enum AdType {
        case interstitial
        case rewarded
    }
    
    var currentAdType: AdType? {
        if FullVersionManager.hasBought {
            return nil
        } else if isDailyTaskLimitExceeded {
            return .rewarded
        } else if currentTaskIndex > 1 {
            return .interstitial
        } else {
            return nil
        }
    }
}

extension MainAdsModel: YMAInterstitialAdDelegate {
    func interstitialAdDidLoad(_ interstitialAd: YMAInterstitialAd) {
        adState = .loaded
    }
    
    func interstitialAdDidFail(toLoad interstitialAd: YMAInterstitialAd, error: Error) {
        adState = .failedToLoad
    }
    
    func interstitialAdDidFail(toPresent interstitialAd: YMAInterstitialAd, error: Error) {
        adState = .failedToPresent
    }
}

extension MainAdsModel: YMARewardedAdDelegate {
    func rewardedAd(_ rewardedAd: YMARewardedAd, didReward reward: YMAReward) {
        rewarded = true
    }
    
    func rewardedAdDidLoad(_ rewardedAd: YMARewardedAd) {
        adState = .loaded
    }
    
    func rewardedAdDidFail(toLoad rewardedAd: YMARewardedAd, error: Error) {
        adState = .failedToLoad
    }
    
    func rewardedAdDidFail(toPresent rewardedAd: YMARewardedAd, error: Error) {
        adState = .failedToPresent
    }
    
    func rewardedAdDidDisappear(_ rewardedAd: YMARewardedAd) {
        adState = .notLoaded
    }
}
