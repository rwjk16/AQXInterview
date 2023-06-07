//
//  RecentTradesViewModel.swift
//  AQXInterview
//
//  Created by Russell Weber on 2023-06-05.
//

import Foundation
import Combine

// RecentTradesViewModel that manages the recent trades view
class RecentTradesViewModel: TabViewModel {
    // Published property to track the recent trades
    @Published var recentTrades = [TradeData]()
    
    // Dispatch queue for managing concurrent access to recentTrades array
    private let queue = DispatchQueue(label: "com.company.app.OrderBookQueue", qos: .userInitiated)
    
    // Maximum number of trades to display
    private let maxTradesCount = 30
    
    init(webSocketClient: WebSocketService,
         coinPair: CoinPair,
         table: SubscriptionTopic = .trade) {
        super.init(title: "Recent Trades",
                   coinPair: coinPair,
                   webSocketClient: webSocketClient,
                   table: table)
        
        webSocketClient.delegate = self
        
        webSocketClient.recentTradesUpdateSubject
            .sink { [weak self] update in
                 self?.processRecentTradeUpdate(update)
            }
            .store(in: &cancellables)
    }
    
    override func subscribe() {
        isLoading = true
        webSocketClient.subscribeRecentTrades(coinPair: coinPair.tradeSymbol)
    }
    
    private func processRecentTradeUpdate(_ update: RecentTradeUpdate) {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            var newTradeEntries = self.recentTrades
            // Recent trades is insert only
            newTradeEntries.insert(contentsOf: update.data, at: 0)
            
            DispatchQueue.main.async {
                // stop spinner since we have valid data now
                self.isLoading = false
                self.recentTrades = Array(newTradeEntries.prefix(self.maxTradesCount))
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    for index in self.recentTrades.indices {
                        if self.recentTrades[index].newEntry {
                            self.recentTrades[index].newEntry = false
                        }
                    }
                }
            }
        }
    }
}
