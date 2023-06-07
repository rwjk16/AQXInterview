//
//  Array+Helper.swift
//  AQXInterview
//
//  Created by Russell Weber on 2023-06-05.
//

import Foundation

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
}

