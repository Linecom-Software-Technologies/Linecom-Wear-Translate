//
//  IAPManager.swift
//  Linecom Wear Translate Watch App
//
//  Created by 澪空 on 2024/7/5.
//

import Foundation
import StoreKit
import SwiftUI

class IAPManager: NSObject, ObservableObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    static let shared = IAPManager()
    
    @Published var monthlyProduct: SKProduct?
    @Published var yearlyProduct: SKProduct?
    @Published var purchaseState: PurchaseState = .idle
    @AppStorage("isSubscribed") var isSubscribed: Bool = false // 存储订阅状态
    var productRequest: SKProductsRequest?
    
    enum PurchaseState {
        case idle
        case purchasing
        case purchased
        case failed(error: Error?)
    }
    
    func fetchProducts() {
        let productIdentifiers = Set(["com.linecom.weartranslate.monthly", "com.linecom.weartranslate.yearly"])
        productRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productRequest?.delegate = self
        productRequest?.start()
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        for product in response.products {
            if product.productIdentifier == "com.linecom.weartranslate.monthly" {
                DispatchQueue.main.async { self.monthlyProduct = product }
            } else if product.productIdentifier == "com.linecom.weartranslate.yearly" {
                DispatchQueue.main.async { self.yearlyProduct = product }
            }
        }
    }
    
    func purchaseProduct(product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
        purchaseState = .purchasing
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                validateReceipt { isValid in
                    DispatchQueue.main.async {
                        if isValid {
                            self.purchaseState = .purchased
                            self.isSubscribed = true // 更新订阅状态
                        } else {
                            self.purchaseState = .failed(error: nil)
                            self.isSubscribed = false
                        }
                    }
                }
                SKPaymentQueue.default().finishTransaction(transaction)
            case .failed:
                DispatchQueue.main.async {
                    self.purchaseState = .failed(error: transaction.error)
                    self.isSubscribed = false
                }
                SKPaymentQueue.default().finishTransaction(transaction)
            case .restored:
                SKPaymentQueue.default().finishTransaction(transaction)
            default:
                break
            }
        }
    }
    
    func validateReceipt(completion: @escaping (Bool) -> Void) {
        guard let receiptURL = Bundle.main.appStoreReceiptURL else {
            completion(false)
            return
        }
        
        do {
            let receiptData = try Data(contentsOf: receiptURL)
            let receiptString = receiptData.base64EncodedString(options: [])
            
            // 将收据发送到服务器
            var request = URLRequest(url: URL(string: "https://api.linecom.net.cn/lwt/validateReceipt")!)
            request.httpMethod = "POST"
            request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            let body = "receipt-data=\(receiptString)"
            request.httpBody = body.data(using: .utf8)
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    completion(false)
                    return
                }
                
                // 解析服务器响应
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let status = json["status"] as? String, status == "success" {
                    completion(true)
                } else {
                    completion(false)
                }
            }.resume()
        } catch {
            completion(false)
        }
    }
    
    func startObserving() {
        SKPaymentQueue.default().add(self)
    }
    
    func stopObserving() {
        SKPaymentQueue.default().remove(self)
    }
    
    func refreshSubscriptionStatus() {
        validateReceipt { isValid in
            DispatchQueue.main.async {
                self.isSubscribed = isValid
            }
        }
    }
}
