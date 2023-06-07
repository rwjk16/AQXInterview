//
//  ContentView.swift
//  AQXInterview
//
//  Created by Russell Weber on 2023-06-01.
//

import SwiftUI

struct ContentView: View {
    // State property to hold the selectedTab
    @State private var selectedTab = 0
    
    // State property to hold the selected coin pairing
    @State private var coinPairing = CoinPair(rootSymbol: "XBT")
    
    // State property to control the visibility of the dropdown
    @State private var showDropdown = false
    
    // State property to hold the available coin pairings
    @State var coinPairings = [CoinPair(rootSymbol: "XBT")]
    
    let webSocket = WebSocketService()
    
    var body: some View {
        VStack {
            // Display the navigation bar view with the necessary bindings and data
            NavigationBarView(coinPairing: $coinPairing,
                              showDropdown: $showDropdown,
                              coinPairings: coinPairings)
            
            CustomTabView(selectedTab: $selectedTab,
                          coinPairing: $coinPairing,
                          webSocket: webSocket)
        }
        .onAppear {
            // Call to update the coin pairings when the view appears
            updateCoinPairs()
        }
    }
    
    func updateCoinPairs() {
        DispatchQueue.global(qos: .background).async {
            // Call the WebSocketService's getCoinList method to fetch the list of coins
            self.webSocket.getCoinList { res in
                switch res {
                case .success(let coins):
                    DispatchQueue.main.async {
                        // Update the coin pairings with the received coins and sort them
                        coinPairings = Set(coins).sorted(by: { $0.rootSymbol < $1.tradeSymbol })
                    }
                case .failure(_):
                    // Handle Error here
                    print("ERROR")
                }
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
