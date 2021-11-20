//
//  ImageButtonStyle.swift
//  SimpleDesktops
//
//  Created by Jiaxin Shou on 2021/2/8.
//

import SwiftUI

struct ImageButtonStyle: ButtonStyle {
    let size: CGSize

    init(size: CGSize = CGSize(width: 32, height: 32)) {
        self.size = size
    }

    func makeBody(configuration: Configuration) -> some View {
        ImageButton(configuration: configuration, size: size)
    }

    struct ImageButton: View {
        let configuration: ButtonStyle.Configuration

        let size: CGSize

        @Environment(\.isEnabled) private var isEnabled: Bool

        @State private var isHovering: Bool = false

        var body: some View {
            configuration.label
                .frame(width: size.width, height: size.height)
                .contentShape(Rectangle())
                .background {
                    RoundedRectangle(cornerRadius: 6)
                        .opacity(isHovering && isEnabled ? 0.2 : 0)
                        .transition(.opacity)
                }
                .foregroundColor(isEnabled ? .primary : .secondary)
                .onHover { isHovering in
                    withAnimation(.easeInOut) {
                        self.isHovering = isHovering
                    }
                }
                .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
        }
    }
}

struct ImageButton_Previews: PreviewProvider {
    static var previews: some View {
        button
            .buttonStyle(ImageButtonStyle(size: CGSize(width: 40, height: 40)))

        button
            .buttonStyle(ImageButtonStyle(size: CGSize(width: 40, height: 40)))
            .disabled(true)
    }

    static var button: some View {
        Button {} label: {
            Image(systemName: "applelogo")
                .font(.largeTitle)
        }
    }
}
