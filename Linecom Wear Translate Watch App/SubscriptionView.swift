//
//  BuyView.swift
//  Linecom Wear Translate Watch App
//
//  Created by 澪空 on 2024/5/11.
//

import SwiftUI
import StoreKit

struct SubscriptionView: View {
    
    @StateObject private var iapManager = IAPManager.shared
    @AppStorage("isSubscribed") private var isSubscribed: Bool = false
    
    var body: some View {
        VStack {
            if iapManager.monthlyProduct != nil && iapManager.yearlyProduct != nil {
                List {
                    SubscriptionOptionView(product: iapManager.monthlyProduct!, manager: iapManager)
                    SubscriptionOptionView(product: iapManager.yearlyProduct!, manager: iapManager)
                }
                .listStyle(DefaultListStyle()) // 使用 DefaultListStyle 替代 InsetGroupedListStyle
            } else {
                ProgressView()
                Text("正在载入订阅选项...")
                    .onAppear {
                        iapManager.startObserving()
                        iapManager.fetchProducts()
                    }
            }
            
            switch iapManager.purchaseState {
            case .idle:
                EmptyView()
            case .purchasing:
                ProgressView("正在购买...")
            case .purchased:
                Text("购买成功")
                    .foregroundColor(.green)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            // Purchase successful actions
                        }
                    }
            case .failed(let error):
                Text("购买失败: \(error?.localizedDescription ?? "未知错误")")
                    .foregroundColor(.red)
            }
        }
        .onDisappear {
            iapManager.stopObserving()
        }
    }
}

struct SubscriptionOptionView: View {
    var product: SKProduct
    @ObservedObject var manager: IAPManager
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(product.localizedTitle)
                .font(.headline)
            Text(product.localizedDescription)
                .font(.subheadline)
            Text("\(product.priceLocale.currencySymbol ?? "")\(product.price)")
                .font(.subheadline)
            
            Button(action: {
                manager.purchaseProduct(product: product)
            }) {
                Text("订阅")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
    }
}

struct SubscriptionView_Previews: PreviewProvider {
    static var previews: some View {
        SubscriptionView()
    }
}
