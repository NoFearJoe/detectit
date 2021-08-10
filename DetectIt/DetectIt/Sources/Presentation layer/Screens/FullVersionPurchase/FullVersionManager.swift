//
//  FullVersionManager.swift
//  DetectItCore
//
//  Created by Илья Харабет on 14/06/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import StoreKit
import SwiftyStoreKit
import DetectItCore

public struct FullVersionManager {
    
    public typealias LoadingCompletion = () -> Void
    
    private static var subscribers = NSMapTable<AnyObject, NSObjectWrapper<LoadingCompletion>>.weakToStrongObjects()
    
    public static func subscribeToProductInfoLoading(_ subscriber: AnyObject, action: @escaping LoadingCompletion) {
        subscribers.setObject(NSObjectWrapper<LoadingCompletion>(action), forKey: subscriber)
    }
    
    // MARK: - State
    
    public static var isLoadingProductInfo = false
    
    private static var product: SKProduct?
        
    private static let receiptStorage = UserDefaults.standard
    
    // MARK: - Getters
    
    public static var productID: String {
        product?.productIdentifier ?? "com.mesterra.detectit.pro"
    }
    
    public static var price: String? {
        product?.localizedPrice
    }
    
    public static var priceValue: Double? {
        product?.price.doubleValue
    }
    
    public static var hasBought: Bool {
        #if targetEnvironment(simulator)
        return false
        #else
        let hasBought = receiptStorage.bool(
            forKey: inAppPurchaseReceiptKey
        )
        
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
            guard let purchase = purchases.first(where: { $0.productId == productID }) else {
                return
            }
            
            switch purchase.transaction.transactionState {
            case .purchased, .restored:
                if purchase.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                }
                
                unlock()
            case .failed, .purchasing, .deferred:
                return
            @unknown default:
                return
            }
        }
    }
    
    public static func obtainProductInfo() {
        isLoadingProductInfo = true
        
        let ids = Set([productID])
        
        SwiftyStoreKit.retrieveProductsInfo(ids) { results in
            Self.product = results.retrievedProducts.first
            
            Self.isLoadingProductInfo = false
            
            Self.subscribers.objectEnumerator()?.allObjects.forEach { ($0 as? NSObjectWrapper<LoadingCompletion>)?.object() }
        }
    }
    
    public static func restorePurchases(completion: ((Bool) -> Void)?) {
        SwiftyStoreKit.restorePurchases { results in
            completion?(results.restoreFailedPurchases.isEmpty)
        }
    }
    
    public static func purchase(completion: @escaping (Error?) -> Void) {
        guard canBuy, let product = product else {
            return
        }
        
        SwiftyStoreKit.purchaseProduct(product) { result in
            switch result {
            case .success:
                unlock()
                completion(nil)
            case let .error(error):
                completion(error)
            }
        }
    }
    
    // MARK: - Utils
    
    static func unlock() {
        receiptStorage.set(true, forKey: inAppPurchaseReceiptKey)
        
        setFullVersionProperty(value: true)
    }
    
    // For unit testing
    static func reset() {
        receiptStorage.removeObject(forKey: inAppPurchaseReceiptKey)
    }
    
}

private extension FullVersionManager {
        
    static let keyPrefix = "in_app_purchase_receipt"
    
    static var inAppPurchaseReceiptKey: String {
        "\(keyPrefix)_\(productID)"
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
