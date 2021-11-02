//
//  CapsuledButtonStyle.swift
//  SimpleDesktops
//
//  Created by Jiaxin Shou on 2021/2/8.
//

import SwiftUI

struct CapsuledButtonStyle: ButtonStyle {
    let size: CGSize

    let strokeWidth: CGFloat

    init(size: CGSize = CGSize(width: 240, height: 40), strokeWidth: CGFloat = 2.0) {
        self.size = size
        self.strokeWidth = strokeWidth
    }

    func makeBody(configuration: Configuration) -> some View {
        CapsuledButton(configuration: configuration, size: size, strokeWidth: strokeWidth)
    }

    struct CapsuledButton: View {
        let configuration: ButtonStyle.Configuration

        let size: CGSize

        let strokeWidth: CGFloat

        @Environment(\.isEnabled) private var isEnabled: Bool

        @State private var isHovering: Bool = false

        var body: some View {
            configuration.label
                .frame(width: size.width, height: size.height, alignment: .center)
                .background(
                    Capsule()
                        .stroke(lineWidth: strokeWidth)
                )
                .contentShape(Capsule())
                .foregroundColor(isEnabled ? (isHovering ? .accentColor : .primary) : .secondary)
                .opacity(configuration.isPressed ? 0.8 : 1.0)
                .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
                .onHover { isHovering in
                    self.isHovering = isHovering
                }
        }
    }
}

struct CapsuledButton_Previews: PreviewProvider {
    static var previews: some View {
        button
            .buttonStyle(CapsuledButtonStyle(size: CGSize(width: 300, height: 60),
                                             strokeWidth: 4.0))

        button
            .buttonStyle(CapsuledButtonStyle(size: CGSize(width: 300, height: 60),
                                             strokeWidth: 4.0))
            .disabled(true)
    }

    static var button: some View {
        Button {} label: {
            Text("CapsuledButton")
                .font(.largeTitle)
        }
    }
}
