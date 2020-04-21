//
//  PaidTaskBundlesManager.swift
//  DetectItCore
//
//  Created by Илья Харабет on 05/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import Foundation
import StoreKit
import SwiftyStoreKit

public enum TasksBundlePurchaseState {
    case free
    case bought
    case paid(price: String)
    case paidLoading
    case paidLocked
    
    public var isAvailable: Bool {
        switch self {
        case .free, .bought:
            return true
        default:
            return false
        }
    }
    
}

public struct PaidTaskBundlesManager {
    
    public typealias LoadingCompletion = () -> Void
    
    private static var subscribers = NSMapTable<AnyObject, NSObjectWrapper<LoadingCompletion>>.weakToStrongObjects()
    
    public static func subscribeToProductsInfoLoading(_ subscriber: AnyObject, action: @escaping LoadingCompletion) {
        subscribers.setObject(NSObjectWrapper<LoadingCompletion>(action), forKey: subscriber)
    }
    
    // MARK: - State
    
    public static var isLoadingProductsInfo = false
    
    private static var products = Set<SKProduct>()
    
    private static let receiptStorage = UserDefaults.standard
    
    // MARK: - Getters
    
    /// Возвращает состояние встроенной покупки для набора заданий с заданным идентификатором.
    /// - Parameter id: Идентификатор набора заданий.
    public static func tasksBundlePurchaseState(id: String) -> TasksBundlePurchaseState {
        guard isPaidBundle(id: id) else {
            return .free
        }
        
        guard !isBoughtBundle(id: id) else {
            return .bought
        }
        
        guard !isLoadingProductsInfo else {
            return .paidLoading
        }
        
        guard
            canBuyBundle(id: id),
            let productID = productIDs[id],
            let product = products.first(where: { $0.productIdentifier == productID }),
            let price = product.localizedPrice
        else {
            return .paidLocked
        }
        
        return .paid(price: price)
    }
    
    public static func price(bundleID: String) -> String? {
        guard
            let productID = productIDs[bundleID],
            let product = products.first(where: { $0.productIdentifier == productID })
        else {
            return nil
        }
        
        return product.localizedPrice
    }
    
    // MARK: - Products managing
    
    public static func completeTransactions() {
        SwiftyStoreKit.completeTransactions { purchases in
            purchases.forEach {
                switch $0.transaction.transactionState {
                case .purchased, .restored:
                    if $0.needsFinishTransaction {
                        SwiftyStoreKit.finishTransaction($0.transaction)
                    }
                    
                    unlockInAppPurchase(id: $0.productId)
                case .failed, .purchasing, .deferred:
                    return
                @unknown default:
                    return
                }
            }
        }
    }
    
    public static func obtainProductsInfo() {
        isLoadingProductsInfo = true
        
        let ids = Set(IDs.allCases.map { $0.rawValue })
        
        SwiftyStoreKit.retrieveProductsInfo(ids) { results in
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            Self.products = results.retrievedProducts
            
            Self.isLoadingProductsInfo = false
            
            Self.subscribers.objectEnumerator()?.allObjects.forEach { ($0 as? NSObjectWrapper<LoadingCompletion>)?.object() }
            }
        }
    }
    
    public static func restorePurchases(completion: ((Bool) -> Void)?) {
        SwiftyStoreKit.restorePurchases { results in
            completion?(results.restoreFailedPurchases.isEmpty)
        }
    }
    
    public static func purchase(bundleID: String, completion: @escaping (Error?) -> Void) {
        guard
            canBuyBundle(id: bundleID),
            let productID = productIDs[bundleID],
            let product = products.first(where: { $0.productIdentifier == productID })
        else {
            return
        }
        
        SwiftyStoreKit.purchaseProduct(product) { result in
            switch result {
            case let .success(purchase):
                unlockInAppPurchase(id: purchase.productId)
                
                completion(nil)
            case let .error(error):
                completion(error)
            }
        }
    }
    
    // MARK: - Utils
    
    static func clearAllPurchasesData() {
        receiptStorage.dictionaryRepresentation().forEach { key, value in
            guard key.hasPrefix(keyPrefix) else { return }
            
            receiptStorage.removeObject(forKey: key)
        }
    }
    
    private static func isPaidBundle(id: String) -> Bool {
        productIDs[id] != nil
    }
    
    private static func isBoughtBundle(id: String) -> Bool {
        guard let productID = productIDs[id] else { return false }
        
        return receiptStorage.bool(
            forKey: makeInAppPurchaseReceiptKey(productID: productID)
        )
    }
    
    private static func canBuyBundle(id: String) -> Bool {
        isPaidBundle(id: id) && SwiftyStoreKit.canMakePayments && !isBoughtBundle(id: id)
    }
    
    static func unlockBundle(id: String) {
        guard let productID = productIDs[id] else { return }
        unlockInAppPurchase(id: productID)
    }
    
    static func unlockInAppPurchase(id: String) {
        receiptStorage.set(true, forKey: makeInAppPurchaseReceiptKey(productID: id))
    }
    
}

private extension PaidTaskBundlesManager {
    
    static let productIDs: [String: String] = [
        "test": IDs.test.rawValue,
        "ww2": IDs.ww2.rawValue
    ]
    
    enum IDs: String, CaseIterable {
        case test = "com.mesterra.detectit.test"
        case ww2 = "com.mesterra.detectit.ww2"
    }
    
}

private extension PaidTaskBundlesManager {
    
    static let keyPrefix = "in_app_purchase_receipt"
    
    static func makeInAppPurchaseReceiptKey(productID: String) -> String {
        "\(keyPrefix)_\(productID)"
    }
    
}
