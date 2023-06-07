//
//  OrderBookViewModel.swift
//  AQXInterview
//
//  Created by Russell Weber on 2023-06-05.
//

import Foundation
import Combine

class OrderBookViewModel: TabViewModel {
    // Published properties for order book entries, buy orders, sell orders, and isLoading status.
    @Published var orderBookEntries = [OrderData]()
    @Published var buyOrders = [OrderData]()
    @Published var sellOrders = [OrderData]()
    
    // Buffers for new order book entries, buy orders, and sell orders.
    private var newOrderBookEntries = [OrderData]()
    private var newBuyOrders = [OrderData]()
    private var newSellOrders = [OrderData]()
    
    // DispatchQueue and DispatchSemaphore for synchronization.
    private let queue = DispatchQueue(label: "com.rwjk.AQXInterview.OrderBookQueue",
                                      qos: .userInitiated)
    private let semaphore = DispatchSemaphore(value: 1)
    
    // Maximum number of orders to display.
    private let maxOrderCount = 20
    
    init(webSocketClient: WebSocketService,
         coinPair: CoinPair,
         table: SubscriptionTopic = .orderBookL2_25) {
        super.init(title: "Order Book",
                   coinPair: coinPair,
                   webSocketClient: webSocketClient,
                   table: .orderBookL2_25)
        webSocketClient.delegate = self

        // Subscribe to order book updates and process them using the provided closure.
        webSocketClient.orderBookUpdateSubject
            .throttle(for: .milliseconds(500),
                      scheduler: DispatchQueue.main,
                      latest: true)
            .sink { [weak self] update in
                self?.processOrderBookUpdate(update)
            }
            .store(in: &cancellables)
    }
    
    override func subscribe() {
        isLoading = true
        // Subscribe to the WebSocket table for the given coin pair.
        webSocketClient.subscribe(to: table.rawValue,
                                  coinPair: coinPair.tradeSymbol)
    }
    
    private func processOrderBookUpdate(_ update: OrderBookUpdate) {
        queue.async {
            self.semaphore.wait()
            
            // Make copies of the current order book entries, buy orders, and sell orders.
            var newOrderBookEntries = self.orderBookEntries
            var newBuyOrders = self.buyOrders
            var newSellOrders = self.sellOrders
            
            // Create a Set to track existing entry IDs.
            var ids = Set(newOrderBookEntries.map { $0.id })
            
            switch update.action {
            case .partial:
                // For a partial update, replace the entire order book entries with the new data.
                newOrderBookEntries.removeAll()
                newOrderBookEntries.append(contentsOf: update.data)
                
                // Filter and sort the new entries for buy and sell orders.
                newBuyOrders = newOrderBookEntries.filter { $0.isBuy }.suffix(20)
                newSellOrders = newOrderBookEntries.filter { !$0.isBuy }.suffix(20)
                
                // Update the Set with the new entry IDs.
                ids = Set(newOrderBookEntries.map { $0.id })
                
            case .insert:
                for entry in update.data {
                    // Only add the entry if its ID isn't already in the Set.
                    if !ids.contains(entry.id) {
                        newOrderBookEntries.append(entry)
                        ids.insert(entry.id)
                        
                        if entry.isBuy {
                            newBuyOrders.append(entry)
                            if newBuyOrders.count > self.maxOrderCount {
                                newBuyOrders.remove(at: 0)
                            }
                        } else {
                            newSellOrders.append(entry)
                            if newSellOrders.count > self.maxOrderCount {
                                newSellOrders.remove(at: 0)
                            }
                        }
                    }
                }
                
            case .update:
                for entry in update.data {
                    if let index = newOrderBookEntries.firstIndex(where: { $0.id == entry.id }) {
                        // Update the corresponding entry in the order book.
                        newOrderBookEntries[index] = entry
                    }
                    
                    if entry.isBuy, let index = newBuyOrders.firstIndex(where: { $0.id == entry.id }) {
                        // Update the corresponding buy order.
                        newBuyOrders[index] = entry
                    }
                    
                    if !entry.isBuy, let index = newSellOrders.firstIndex(where: { $0.id == entry.id }) {
                        // Update the corresponding sell order.
                        newSellOrders[index] = entry
                    }
                }
                
            case .delete:
                // Remove the entries that are present in the update data.
                newOrderBookEntries.removeAll(where: { entry in update.data.contains(where: { $0.id == entry.id }) })
                newBuyOrders.removeAll(where: { entry in update.data.contains(where: { $0.id == entry.id }) })
                newSellOrders.removeAll(where: { entry in update.data.contains(where: { $0.id == entry.id }) })
            }
            
            self.semaphore.signal()
            
            DispatchQueue.main.async {
                self.isLoading = false
                self.orderBookEntries = newOrderBookEntries
                
                // Sort the buy and sell orders based on their price.
                self.buyOrders = newBuyOrders.sorted(by: { $0.price ?? .zero > $1.price ?? .zero })
                self.sellOrders = newSellOrders.sorted(by: { $0.price ?? .zero < $1.price ?? .zero })
            }
        }
    }
}


class TabViewModel: ObservableObject {
    // Published property to track current coinPair
    @Published var coinPair: CoinPair
    
    @Published var isLoading: Bool = false
    
    // Property to track the title used in the TabView
    let title: String
    
    // Properties used for networking
    internal let table: SubscriptionTopic
    internal var webSocketClient: WebSocketService
    internal var cancellables = Set<AnyCancellable>()

    
    init(title: String,
         coinPair: CoinPair,
         webSocketClient: WebSocketService,
         table: SubscriptionTopic) {
        self.title = title
        self.coinPair = coinPair
        self.webSocketClient = webSocketClient
        self.table = table
        
        $coinPair
            .sink { [weak self] _ in
                // When the coinPair changes, disconnect and connect the socket, then subscribe again
                self?.unsubscribe()
                self?.subscribe()
            }
            .store(in: &cancellables)
    }
    
    
    
    func connect() {
        webSocketClient.connect()
    }
    
    func disconnect() {
        webSocketClient.disconnect()
    }
    
    func unsubscribe() {
        isLoading = true
        webSocketClient.unsubscribe()
    }
    
    func subscribe() {} // to be overwritten
    
    func cancel() {
        cancellables.forEach({ $0.cancel() })
    }
}

extension TabViewModel: WebSocketServiceDelegate {
    func reconnect() {
        unsubscribe()
        subscribe()
    }
}
