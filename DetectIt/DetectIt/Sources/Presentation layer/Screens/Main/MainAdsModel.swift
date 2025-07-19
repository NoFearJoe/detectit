//import SwiftUI
//import Combine
//import YandexMobileAds
//import DetectItCore
//
//final class MainAdsModel: NSObject, ObservableObject {
//    @Published var currentTaskIndex = 0
//    @Published var isDailyTaskLimitExceeded = false
//    
//    @Published private var adState = AdState.notLoaded
//    @Published private var rewarded = false
//    
//    private var interstitialAd: InterstitialAd?
//    private let interstitialAdLoader = InterstitialAdLoader()
//    private var rewardedAd: RewardedAd?
//    private let rewardedAdLoader = RewardedAdLoader()
//    
//    private var hasBeenPresented = false
//    
//    private var presentationCompletion: (() -> Void)?
//    
//    private var cancellables = Set<AnyCancellable>()
//    
//    #if DEBUG
//    private static let interstitialAdID = "demo-interstitial-yandex"
//    #else
//    private static let interstitialAdID = "R-M-2491983-1"
//    #endif
//    
//    #if DEBUG
//    private static let rewardedAdID = "demo-rewarded-yandex"
//    #else
//    private static let rewardedAdID = "R-M-2496182-1"
//    #endif
//    
//    func loadAds() {
//        switch currentAdType {
//        case .interstitial:
//            adState = .loading
//            hasBeenPresented = false
//            interstitialAdLoader.delegate = self
//            interstitialAdLoader.loadAd(with: AdRequestConfiguration(adUnitID: Self.interstitialAdID))
//        case .rewarded:
//            adState = .loading
//            hasBeenPresented = false
//            rewardedAdLoader.delegate = self
//            rewardedAdLoader.loadAd(with: AdRequestConfiguration(adUnitID: Self.rewardedAdID))
//        default:
//            break
//        }
//    }
//    
//    var needToShowAd: Bool {
//        if currentAdType == .none {
//            return false
//        } else {
//            return !hasBeenPresented
//        }
//    }
//    
//    enum PresentationState {
//        case loading
//        case presented
//        case completed(rewarded: Bool)
//        case failed
//    }
//    
//    func present(
//        allowFailure: Bool,
//        onStateChange: @escaping (PresentationState) -> Void
//    ) {
//        present(
//            state: adState,
//            allowFailure: allowFailure,
//            attempt: 0,
//            onStateChange: onStateChange
//        )
//    }
//    
//    private func present(
//        state: AdState,
//        allowFailure: Bool,
//        attempt: Int,
//        onStateChange: @escaping (PresentationState) -> Void
//    ) {
//        switch state {
//        case .notLoaded:
//            loadAds() // TODO
//            present(
//                state: adState,
//                allowFailure: allowFailure,
//                attempt: attempt,
//                onStateChange: onStateChange
//            )
//        case .loading:
//            onStateChange(.loading)
//            
//            $adState
//                .removeDuplicates()
//                .filter { $0 != .loading && $0 != .notLoaded }
//                .sink { [weak self] state in
//                    self?.present(
//                        state: state,
//                        allowFailure: allowFailure,
//                        attempt: attempt,
//                        onStateChange: onStateChange
//                    )
//                }
//                .store(in: &cancellables)
//        case .loaded:
//            onStateChange(.presented)
//            cancellables.removeAll()
//            
//            let vc = UIApplication.topViewController()
//            vc.map {
//                presentAd(from: $0) { [weak self] in
//                    guard let self else { return }
//                    
//                    onStateChange(.completed(rewarded: self.rewarded))
//                    
//                    self.rewarded = false
//                }
//            }
//        case .failedToLoad, .failedToPresent:
//            cancellables.removeAll()
//            
//            if allowFailure {
//                onStateChange(.completed(rewarded: false))
//            } else if attempt < 3 {
//                DispatchQueue.main.asyncAfter(deadline: .now() + Double(attempt + 1)) {
//                    self.loadAds()
//                    self.present(
//                        state: self.adState,
//                        allowFailure: allowFailure,
//                        attempt: attempt + 1,
//                        onStateChange: onStateChange
//                    )
//                }
//            } else {
//                onStateChange(.failed)
//            }
//        }
//    }
//    
//    private func presentAd(from vc: UIViewController, completion: @escaping () -> Void) {
//        switch currentAdType {
//        case .interstitial:
//            self.presentationCompletion = completion
//            interstitialAd?.show(from: vc)
//        case .rewarded:
//            self.presentationCompletion = completion
//            rewardedAd?.show(from: vc)
//        default:
//            break
//        }
//    }
//}
//
//extension MainAdsModel {
//    enum AdState {
//        case notLoaded
//        case loading
//        case loaded
//        case failedToLoad
//        case failedToPresent
//    }
//}
//    
//private extension MainAdsModel {
//    enum AdType {
//        case interstitial
//        case rewarded
//    }
//    
//    var currentAdType: AdType? {
//        if FullVersionManager.hasBought {
//            return nil
//        } else if isDailyTaskLimitExceeded {
//            return .rewarded
//        } else if currentTaskIndex > 1 {
//            return .interstitial
//        } else {
//            return nil
//        }
//    }
//}
//
//extension MainAdsModel: InterstitialAdLoaderDelegate, InterstitialAdDelegate {
//    func interstitialAdLoader(_ adLoader: YandexMobileAds.InterstitialAdLoader, didLoad interstitialAd: YandexMobileAds.InterstitialAd) {
//        self.interstitialAd = interstitialAd
//        interstitialAd.delegate = self
//        
//        adState = .loaded
//    }
//    
//    func interstitialAdLoader(_ adLoader: YandexMobileAds.InterstitialAdLoader, didFailToLoadWithError error: YandexMobileAds.AdRequestError) {
//        adState = .failedToLoad
//    }
//    
//    func interstitialAdDidShow(_ interstitialAd: InterstitialAd) {
//        hasBeenPresented = true
//    }
//    
//    func interstitialAdDidDismiss(_ interstitialAd: InterstitialAd) {
//        adState = .notLoaded
//        presentationCompletion?()
//    }
//    
//    func interstitialAd(_ interstitialAd: InterstitialAd, didFailToShowWithError error: any Error) {
//        adState = .failedToPresent
//    }
//}
//
//extension MainAdsModel: RewardedAdLoaderDelegate, RewardedAdDelegate {
//    func rewardedAdLoader(_ adLoader: YandexMobileAds.RewardedAdLoader, didLoad rewardedAd: YandexMobileAds.RewardedAd) {
//        self.rewardedAd = rewardedAd
//        rewardedAd.delegate = self
//        
//        adState = .loaded
//    }
//    
//    func rewardedAdLoader(_ adLoader: YandexMobileAds.RewardedAdLoader, didFailToLoadWithError error: YandexMobileAds.AdRequestError) {
//        adState = .failedToLoad
//    }
//    
//    func rewardedAdDidShow(_ rewardedAd: RewardedAd) {
//        hasBeenPresented = true
//    }
//    
//    func rewardedAdDidDismiss(_ rewardedAd: RewardedAd) {
//        adState = .notLoaded
//        presentationCompletion?()
//        rewarded = false
//    }
//    
//    func rewardedAd(_ rewardedAd: RewardedAd, didFailToShowWithError error: any Error) {
//        adState = .failedToPresent
//    }
//    
//    func rewardedAd(_ rewardedAd: RewardedAd, didReward reward: Reward) {
//        rewarded = true
//    }
//}
