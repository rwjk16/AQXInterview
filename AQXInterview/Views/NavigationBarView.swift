//
//  NavigationBarView.swift
//  AQXInterview
//
//  Created by Russell Weber on 2023-06-06.
//

import SwiftUI

// NavigationBarView that represents a custom navigation bar
struct NavigationBarView: View {
    // The selected coin pairing
    @Binding var coinPairing: CoinPair

    // Flag to control the display of the dropdown menu
    @Binding var showDropdown: Bool

    // Array of coin pairings to populate the dropdown menu
    let coinPairings: [CoinPair]

    var body: some View {
        HStack {
            // Back button
            Button(action: {
                // Implement back action
            }) {
                Image(systemName: "arrow.left")
                    .foregroundColor(.gray)
            }

            Spacer()

            // Dropdown menu
            Menu {
                ForEach(coinPairings, id: \.self) { pairing in
                    Button(action: {
                        coinPairing = pairing
                    }) {
                        Text(pairing.tradeSymbol)
                    }
                }
            } label: {
                HStack(spacing: 2.0) {
                    Text(coinPairing.tradeSymbol)
                        .font(.headline)
                        .foregroundColor(.black)
                    Image(systemName: "chevron.up.chevron.down")
                        .foregroundColor(.black)
                }
            }

            Spacer()

            // Favorite button
            Button(action: {
                // Implement favorite action
            }) {
                Image(systemName: "star")
            }
        }
        .padding()
    }
}
