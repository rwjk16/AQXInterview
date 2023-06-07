//
//  CustomTabView.swift
//  AQXInterview
//
//  Created by Russell Weber on 2023-06-06.
//

import SwiftUI

// CustomTabView that represents a custom tab view
struct CustomTabView: View {
    // The index of the selected tab
    @Binding var selectedTab: Int

    // The selected coin pairing
    @Binding var coinPairing: CoinPair
    let webSocket: WebSocketService

    var body: some View {
        VStack {
            // CustomPicker used for tab selection
            CustomPicker(selection: $selectedTab, labels: ["Order Book", "Recent Trades"])
                .padding(.horizontal, 8.0)

            // Show the appropriate view based on the selected tab
            if selectedTab == 0 {
                let vm = OrderBookViewModel(webSocketClient: webSocket,
                                            coinPair: coinPairing)
                OrderBookView(viewModel: vm)
            } else if selectedTab == 1 {
                let vm = RecentTradesViewModel(webSocketClient: webSocket,
                                               coinPair: coinPairing)
                RecentTradesView(viewModel: vm)
            }
        }
    }
}

