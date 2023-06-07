//
//  DataModels.swift
//  AQXInterview
//
//  Created by Russell Weber on 2023-06-05.
//

import Foundation

// Represents a WebSocket message with an operation and arguments
struct WebSocketMessage: Codable {
    let op: String  // The operation
    let args: [String]  // The arguments
}

// Represents an order book update with table information, action type, and order data
struct OrderBookUpdate: Codable {
    let table: String  // The table name
    let action: TableAction  // The action type
    let data: [OrderData]  // The array of order data
}

// Represents a recent trade update with table information, action type, keys, types, filter, and trade data
struct RecentTradeUpdate: Codable {
    let table: String  // The table name
    let action: TableAction  // The action type
    let keys: [String]?
    let types: [String: String]?
    let filter: Filter?
    let data: [TradeData]  // The array of trade data
}

// Represents a filter with a symbol for trade data
struct Filter: Codable {
    let symbol: String
}

// Represents trade data with various properties and conforming to Identifiable protocol
struct TradeData: Codable, Identifiable {
    var id = UUID()  // Unique identifier
    var newEntry: Bool  // Indicates if it's a new entry

    let timestamp: String  // The timestamp of the trade
    let symbol: String  // The symbol of the trade
    let side: String  // The side of the trade (Buy or Sell)
    let size: Int  // The size of the trade
    let price: Float  // The price of the trade
    let tickDirection: String  // The tick direction of the trade
    let trdMatchID: String  // The trade match ID
    let grossValue: Int  // The gross value of the trade
    let homeNotional: Float  // The home notional value
    let foreignNotional: Float  // The foreign notional value
    let trdType: String  // The trade type

    enum CodingKeys: CodingKey {
        case timestamp, symbol, side, size, price, tickDirection, trdMatchID, grossValue, homeNotional, foreignNotional, trdType
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        timestamp = try container.decode(String.self, forKey: .timestamp)
        symbol = try container.decode(String.self, forKey: .symbol)
        side = try container.decode(String.self, forKey: .side)
        size = try container.decode(Int.self, forKey: .size)
        price = try container.decode(Float.self, forKey: .price)
        tickDirection = try container.decode(String.self, forKey: .tickDirection)
        trdMatchID = try container.decode(String.self, forKey: .trdMatchID)
        grossValue = try container.decode(Int.self, forKey: .grossValue)
        homeNotional = try container.decode(Float.self, forKey: .homeNotional)
        foreignNotional = try container.decode(Float.self, forKey: .foreignNotional)
        trdType = try container.decode(String.self, forKey: .trdType)

        newEntry = true
    }
    
    // Returns whether the trade is a buy trade
    var isBuy: Bool {
        side == "Buy"
    }
    
    // Returns a formatted string for the recent trade time
    func recentTradeTime() -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.locale = Locale(identifier: "en_US_POSIX")

        if let date = formatter.date(from: timestamp) {
            formatter.dateFormat = "HH:mm:ss"
            let outputString = formatter.string(from: date)
            return outputString
        } else {
            print("Failed to parse the input date string")
            return nil
        }
    }
}

// Represents an action type for table updates
enum TableAction: String, Codable {
    case partial, update, delete, insert
}

// Represents order data with symbol, ID, side, size, and price properties, and conforming to Identifiable and Equatable protocols
struct OrderData: Codable, Identifiable, Equatable {
    let symbol: String  // The symbol
    let id: Int  // The ID
    let side: String  // The side (Buy or Sell)
    let size: Int?  // Optional size
    let price: Double?  // Optional price

    // Returns whether the order is a buy order
    var isBuy: Bool {
        side == "Buy"
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.symbol == rhs.symbol && lhs.id == rhs.id && lhs.side == rhs.side && lhs.size == rhs.size && lhs.price == rhs.price
    }
}

// Represents a model that can be decoded from JSON data, with cases for different data models
enum Model: Decodable {
    case order([OrderData])  // Represents an array of order data
    case orderUpdate(OrderBookUpdate)  // Represents an order book update
    case trade([TradeData])  // Represents an array of trade data
    case tradeUpdate(RecentTradeUpdate)  // Represents a recent trade update

    init(from decoder: Decoder) throws {
        if let order = try? [OrderData](from: decoder) {
            self = .order(order)
            return
        }
        if let orderUpdate = try? OrderBookUpdate(from: decoder) {
            self = .orderUpdate(orderUpdate)
            return
        }
        if let trade = try? [TradeData](from: decoder) {
            self = .trade(trade)
            return
        }
        if let tradeUpdate = try? RecentTradeUpdate(from: decoder) {
            self = .tradeUpdate(tradeUpdate)
            return
        }

        throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath,
                                                debugDescription: "Data doesn't match any known model"))
    }
}

// Represents a coin pair, with a root symbol and a computed trade symbol
struct CoinPair: Decodable, Hashable, Identifiable {
    var id = UUID()  // Unique identifier

    let rootSymbol: String  // The root symbol
    var tradeSymbol: String {
        rootSymbol + "USD"  // The trade symbol (can be customized)
    }
    
    enum CodingKeys: CodingKey {
        case rootSymbol
    }

    // Implements Equatable protocol by comparing root symbols for equality
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.rootSymbol == rhs.rootSymbol
    }

    // Implements Hashable protocol by hashing the root symbol
    func hash(into hasher: inout Hasher) {
        hasher.combine(rootSymbol)
    }
}
