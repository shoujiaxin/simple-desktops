//
//  ImageButton.swift
//  Simple Desktops
//
//  Created by Jiaxin Shou on 2021/1/15.
//

import SwiftUI

struct ImageButton<Content: View>: View {
    private let image: Content
    private let size: CGSize
    private let action: () -> Void

    init(image: () -> Content, size: CGSize = CGSize(width: 32, height: 32), action: @escaping () -> Void) {
        self.image = image()
        self.size = size
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            image
                .frame(width: size.width, height: size.height)
                .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ImageButton_Previews: PreviewProvider {
    static var previews: some View {
        ImageButton(image: {
            Image(systemName: "applelogo")
        }) {}
    }
}
