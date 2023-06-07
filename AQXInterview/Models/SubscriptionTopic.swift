//
//  SubscriptionTopic.swift
//  AQXInterview
//
//  Created by Russell Weber on 2023-06-05.
//

import Foundation

enum SubscriptionTopic: String, Codable {
    case funding,             // Updates of swap funding rates. Sent every funding interval (usually 8hrs)
    instrument,         // Instrument updates including turnover and bid/ask (Special filters: CONTRACTS, INDICES, DERIVATIVES, SPOT)
    insurance,           // Daily Insurance Fund updates
    liquidation,         // Liquidation orders as they're entered into the book
    orderBookL2_25,      // Top 25 levels of level 2 order book
    orderBookL2,         // Full level 2 order book
    orderBook10,         // Top 10 levels using traditional full book push
    quoteBin1m,          // 1-minute quote bins
    quoteBin5m,          // 5-minute quote bins
    quoteBin1h,          // 1-hour quote bins
    quoteBin1d,          // 1-day quote bins
    settlement,          // Settlements
    trade,               // Live trades
    tradeBin1m,          // 1-minute trade bins
    tradeBin5m,          // 5-minute trade bins
    tradeBin1h,          // 1-hour trade bins
    tradeBin1d
    
    case quo = "quote"               // Top level of the book
}
