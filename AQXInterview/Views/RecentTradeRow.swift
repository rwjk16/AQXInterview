//
//  RecentTradeRow.swift
//  AQXInterview
//
//  Created by Russell Weber on 2023-06-06.
//

import SwiftUI

struct RecentTradeRow: View {
    let trade: TradeData
    // Number formatter for displaying currency values
    let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        return formatter
    }()
    var body: some View {
        // trade price, quantity, and timestamp
        HStack {
            Text("\(currencyFormatter.string(from: trade.price as NSNumber) ?? "")")
                .frame(width: 150)
            Spacer()
            Text("\(trade.size)")
                .frame(width: 100)
            Spacer()
            Text(trade.recentTradeTime() ?? "")
                .frame(width: 150)
        }
        .edgesIgnoringSafeArea(.all)
        .frame(minHeight: 50)
        .foregroundColor(trade.isBuy ? .green : .red)
        .modifier(FlashBackground(isBuy: trade.isBuy, newEntry: trade.newEntry))
        .animation(.easeInOut, value: trade.newEntry)
    }
}
