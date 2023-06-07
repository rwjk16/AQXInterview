//
//  RecentTradesView.swift
//  AQXInterview
//
//  Created by Russell Weber on 2023-06-05.
//

import SwiftUI

// RecentTradesView that displays the recent trades
struct RecentTradesView: View {
    // The view model used to update the view
    @ObservedObject var viewModel: RecentTradesViewModel
    
    var body: some View {
        VStack {
            // Headline
            Text("Recent Trades")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 8)
                .padding(.horizontal, 16)
            // Column Headers
            HStack {
                Text("Price (USD)")
                    .frame(width: 150)
                Spacer()
                Text("Qty")
                    .frame(width: 100)
                Spacer()
                Text("Time")
                    .frame(width: 150)
            }
            .padding(.bottom, 8)
            
            ScrollView {
                ForEach(viewModel.recentTrades) { trade in
                    // Row to diplay trade data
                    RecentTradeRow(trade: trade)
                }
            }
        }
        .background(Color.clear)
        .overlay(
            Group {
                // Show a progress indicator if the view model is loading data.
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(2, anchor: .center)
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                }
            }
        )
        .onAppear {
            // Connect to the data source when the view appears.
            viewModel.connect()
            viewModel.subscribe()
        }
        .onDisappear {
            // Disconnect from the data source when the view disappears
            viewModel.cancel()
        }
    }
}
struct RecentTradesView_Previews: PreviewProvider {
    static var previews: some View {
        let vm = RecentTradesViewModel(webSocketClient: WebSocketService(),
                                       coinPair: CoinPair(rootSymbol: "XBT"))
        RecentTradesView(viewModel: vm)
    }
}
