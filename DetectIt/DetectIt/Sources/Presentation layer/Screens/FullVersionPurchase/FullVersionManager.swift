import StoreKit
import SwiftyStoreKit
import DetectItCore

public struct FullVersionManager {
    
    public typealias LoadingCompletion = () -> Void
    
    public enum Product: String, CaseIterable {
        case pro
        
        public var id: String {
            "com.mesterra.detectit.\(rawValue)"
        }
    }
    
    private static var subscribers = NSMapTable<AnyObject, NSObjectWrapper<LoadingCompletion>>.weakToStrongObjects()
    
    public static func subscribeToProductInfoLoading(_ subscriber: AnyObject, action: @escaping LoadingCompletion) {
        subscribers.setObject(NSObjectWrapper<LoadingCompletion>(action), forKey: subscriber)
    }
    
    // MARK: - State
    
    public static var isLoadingProductInfo = false
    
    private static var products = [SKProduct]()
        
    private static let receiptStorage = UserDefaults.standard
    
    // MARK: - Getters
    
    public static func price(for product: Product) -> String? {
        products.first(where: { $0.productIdentifier == product.id })?.localizedPrice
    }
    
    public static func priceValue(for product: Product) -> Double? {
        products.first(where: { $0.productIdentifier == product.id })?.price.doubleValue
    }
    
    public static var hasBought: Bool {
        #if targetEnvironment(simulator)
        return false
        #else
        let hasBought = Product.allCases.contains {
            receiptStorage.bool(forKey: inAppPurchaseReceiptKey(for: $0))
        } || receiptStorage.bool(forKey: inAppPurchaseOldReceiptKey)
        
        setFullVersionProperty(value: hasBought)
        
        return hasBought
        #endif
    }
    
    public static var canBuy: Bool {
        SwiftyStoreKit.canMakePayments && !hasBought
    }
    
    // MARK: - Products managing
    
    public static func completeTransactions() {
        SwiftyStoreKit.completeTransactions { purchases in
            let purchases = purchases.filter { p in Product.allCases.contains(where: { p.productId == $0.id }) }
            
            purchases.forEach { purchase in
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    
                    if let product = Product.allCases.first(where: { $0.id == purchase.productId }) {
                        unlock(product: product)
                    }
                case .failed, .purchasing, .deferred:
                    return
                @unknown default:
                    return
                }
            }
        }
    }
    
    public static func obtainProductInfo() {
        isLoadingProductInfo = true
        
        let ids = Set(Product.allCases.map { $0.id })
        
        SwiftyStoreKit.retrieveProductsInfo(ids) { results in
            Self.products = Array(results.retrievedProducts)
            
            Self.isLoadingProductInfo = false
            
            Self.subscribers.objectEnumerator()?.allObjects.forEach { ($0 as? NSObjectWrapper<LoadingCompletion>)?.object() }
        }
    }
    
    public static func restorePurchases(completion: ((Bool) -> Void)?) {
        SwiftyStoreKit.restorePurchases { results in
            completion?(results.restoreFailedPurchases.isEmpty)
        }
    }
    
    public static func purchase(product: Product, completion: @escaping (Error?) -> Void) {
        guard canBuy, let skProduct = products.first(where: { $0.productIdentifier == product.id }) else {
            return
        }
        
        SwiftyStoreKit.purchaseProduct(skProduct) { result in
            switch result {
            case .success:
                unlock(product: product)
                completion(nil)
            case let .error(error):
                completion(error)
            }
        }
    }
    
    // MARK: - Utils
    
    static func unlock(product: Product) {
        receiptStorage.set(true, forKey: inAppPurchaseReceiptKey(for: product))
        
        setFullVersionProperty(value: true)
    }
    
    // For unit testing
    static func reset() {
        Product.allCases.forEach {
            receiptStorage.removeObject(forKey: inAppPurchaseReceiptKey(for: $0))
        }
    }
    
}

private extension FullVersionManager {
        
    static let keyPrefix = "in_app_purchase_receipt"
    
    static func inAppPurchaseReceiptKey(for product: Product) -> String {
        "\(keyPrefix)_\(product.id)"
    }
    
    static var inAppPurchaseOldReceiptKey: String {
        "in_app_purchase_receipt_com.mesterra.detectit.pro"
    }
    
}

private extension FullVersionManager {
    
    static var fullVersionPropertySet = false
    
    static func setFullVersionProperty(value: Bool) {
        guard !fullVersionPropertySet else { return }
        
        fullVersionPropertySet = true
        
        Analytics.setProperty("full_version", value: value)
    }
    
}
