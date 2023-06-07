//
//  OrderBookView.swift
//  AQXInterview
//
//  Created by Russell Weber on 2023-06-05.
//

import SwiftUI

struct OrderBookView: View {
    @ObservedObject var viewModel: OrderBookViewModel
    
    var body: some View {
        VStack {
            HStack {
                Text("Quantity")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Price (USD)")
                    .frame(maxWidth: .infinity)
                Text("Quantity")
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.horizontal) // Applies horizontal padding to the HStack
            
            GeometryReader { geometry in
                let buyOrders = viewModel.buyOrders
                let sellOrders = viewModel.sellOrders
                // Chooses the smaller array between buyOrders and sellOrders
                let orders: [OrderData] = (buyOrders.count > sellOrders.count) ? sellOrders : buyOrders
                let standardRowHeight: CGFloat = 50 // Defines the standard row height
                let totalOrderHeight = standardRowHeight * CGFloat(orders.count) // Calculates the total height of all rows
                let rowHeight = totalOrderHeight < geometry.size.height ? geometry.size.height / CGFloat(orders.count) : standardRowHeight // Determines the row height based on available space and total row count
                
                List {
                    ForEach(orders.indices, id: \.self) { index in
                        let buy = buyOrders[safe: index]
                        let sell = sellOrders[safe: index]
                        OrderBookRow(buyOrder: buy, sellOrder: sell)
                            .frame(height: rowHeight)
                            .listRowInsets(EdgeInsets(top: 0.0,
                                                      leading: 16.0,
                                                      bottom: 0.0,
                                                      trailing: 16.0))
                    }
                }
                .scrollIndicators(.hidden)
                .listStyle(PlainListStyle()) // Sets the list style to plain
                
            }
        }
        .overlay(
            Group {
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(2, anchor: .center) // Scales up the size of the ProgressView
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue)) // Applies a blue tint to the ProgressView
                }
            }
        )
        .onAppear {
            viewModel.connect() // Establishes a connection when the view appears
            viewModel.subscribe() // Subscribes to relevant data updates
        }
        .onDisappear {
            viewModel.cancel() // Disconnects when the view disappears
        }
    }
}
