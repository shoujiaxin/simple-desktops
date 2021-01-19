//
//  CapsuleButton.swift
//  Simple Desktops
//
//  Created by Jiaxin Shou on 2021/1/15.
//

import SwiftUI

struct CapsuleButton: View {
    var title: LocalizedStringKey
    var size: CGSize
    var action: () -> Void

    init(_ title: LocalizedStringKey, size: CGSize = CGSize(width: 240, height: 40), action: @escaping () -> Void) {
        self.title = title
        self.size = size
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            ZStack {
                Capsule()
                    .stroke(lineWidth: strokeLineWidth)

                Text(title)
                    .frame(width: size.width, height: size.height)
                    .contentShape(Capsule())
            }
        }
        .frame(width: size.width, height: size.height)
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Draw Constants

    private let strokeLineWidth: CGFloat = 2.0
}

struct CapsuleButton_Previews: PreviewProvider {
    static var previews: some View {
        CapsuleButton("Test Button") {}
    }
}
