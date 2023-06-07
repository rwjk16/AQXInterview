//
//  FlashBackgroudModifier.swift
//  AQXInterview
//
//  Created by Russell Weber on 2023-06-06.
//

import SwiftUI

struct FlashBackground: ViewModifier {
    // Property used to determine which colour to flash
    let isBuy: Bool
    // Property used to determine whether or not to show the bg change
    let newEntry: Bool

    func body(content: Content) -> some View {
        content
            .background(newEntry ? (isBuy ? Color.green.opacity(0.3) : Color.red.opacity(0.3)) : Color.clear)
    }
}
