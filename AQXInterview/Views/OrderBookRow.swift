//
//  OrderBookRow.swift
//  AQXInterview
//
//  Created by Russell Weber on 2023-06-05.
//

import SwiftUI

struct OrderBookRow: View {
    // The buy order on the leftSide
    let buyOrder: OrderData?
    
    // the sell order on the rightSide
    let sellOrder: OrderData?
    
    // The currency formatter used to display Currency
    let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        return formatter
    }()
    
    var body: some View {
        HStack(spacing: .zero) {
            // Buy Order
            ZStack {
                GeometryReader { geometry in
                    Rectangle()
                        .fill(Color.green.opacity(0.3))
                        .frame(width: geometry.size.width * CGFloat(buyOrder?.size ?? .zero) / 1000.0)
                        .offset(x: geometry.size.width - geometry.size.width * CGFloat(buyOrder?.size ?? .zero) / 1000.0)
                }
                HStack {
                    if let buyOrder = buyOrder,
                       let size = buyOrder.size,
                       let price = buyOrder.price {
                        Text("\(size)")
                            .font(.headline)
                        Spacer()
                        Text("\(currencyFormatter.string(from: NSNumber(value: price)) ?? "")")
                            .font(.headline)
                    }
                }
                .foregroundColor(.green)
                .padding(.trailing, 4.0)
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Sell Order
            ZStack {
                GeometryReader { geometry in
                    Rectangle()
                        .fill(Color.red.opacity(0.3))
                        .frame(width: geometry.size.width * CGFloat(sellOrder?.size ?? .zero) / 1000.0)
                }
                HStack {
                    if let sellOrder = sellOrder,
                       let size = sellOrder.size,
                       let price = sellOrder.price {
                        Text("\(currencyFormatter.string(from: NSNumber(value: price)) ?? "")")
                            .font(.headline)
                        Spacer()
                        Text("\(size)")
                            .font(.headline)
                    }
                    
                }
                .foregroundColor(.red)
                .padding(.leading, 4.0)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .frame(maxWidth: .infinity)
        .frame(maxHeight: 250)
    }
}

struct OrderBookRow_Previews: PreviewProvider {
    
    static var previews: some View {
        OrderBookRow(buyOrder: OrderData(symbol: "XBTUSD",
                                         id: 132309831, side: "Buy", size: 120, price: 28374.40),
                     sellOrder: OrderData(symbol: "XBTUSD",
                                          id: 1323091231, side: "Sell", size: 12000, price: 38374.40))
    }
}
