//
//  CustomPicker.swift
//  AQXInterview
//
//  Created by Russell Weber on 2023-06-01.
//

import SwiftUI

// CustomPicker View that provides a custom picker UI
struct CustomPicker: View {
    // The index of the selected label
    @Binding var selection: Int

    // The labels to be displayed in the picker
    let labels: [String]

    // The width of the line that indicates the current selection
    @State private var lineWidth: CGFloat = 0

    // The offset of the line that indicates the current selection
    @State private var lineOffset: CGFloat = 0

    // The body of the view
    var body: some View {
        // GeometryReader is used to measure the view's size
        GeometryReader { geometry in
            VStack(alignment: .leading) {
                HStack(spacing: 0) {
                    // For each label in the labels array
                    ForEach(labels.indices) { index in
                        // Create a text view with the label
                        Text(labels[index])
                            .font(.headline)
                            .foregroundColor(.gray)
                            .frame(width: geometry.size.width / 2, alignment: .center)
                            .onTapGesture {
                                // When this text view is tapped
                                // Animate the change in selection and lineOffset
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    selection = index
                                    lineOffset = lineWidth * CGFloat(index)
                                }
                            }
                    }
                }
                // The rectangle view that indicates the current selection
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: lineWidth, height: 2)
                    .offset(x: lineOffset)
            }
            // Set the initial lineWidth and lineOffset when the view appears
            .onAppear {
                lineWidth = geometry.size.width / 2
                lineOffset = lineWidth * CGFloat(selection)
            }
        }
        // Set a fixed height for the picker
        .frame(height: 50)
    }
}


struct CustomPicker_Previews: PreviewProvider {

    static var previews: some View {
        CustomPicker(selection: Binding(get: {0}, set: {_ in}),
                     labels: ["Order Book", "Recent Trades"])
    }
}

