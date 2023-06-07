//
//  Order.swift
//  AQXInterview
//
//  Created by Russell Weber on 2023-06-01.
//

import Foundation

struct Order: Identifiable {
    let id: Int
    let symbol: String
    let side: String
    let size: Int
    let price: Float
    let timestamp: Date
}
