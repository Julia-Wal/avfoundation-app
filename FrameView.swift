//
//  FrameView.swift
//  seminar-app
//
//  Created by Julia Walczak on 01.11.26.
//

import SwiftUI

struct FrameView: View {
    var image: CGImage?
    private let label = Text("Frame")
    var body: some View {
        if let image = image {
            Image(image, scale: 1.0, orientation: .up, label: label)
        } else{ // no image 
            Color.black
        }
    }
}
