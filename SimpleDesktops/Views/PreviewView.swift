//
//  PreviewView.swift
//  Simple Desktops
//
//  Created by Jiaxin Shou on 2021/1/14.
//

import SDWebImageSwiftUI
import SwiftUI

struct PreviewView: View {
    var wallpaper: Wallpaper?

    @State private var buttonOpacity: Double = 0.2

    init(of wallpaper: Wallpaper?) {
        self.wallpaper = wallpaper
    }

    var body: some View {
        ZStack {
            WebImage(url: wallpaper?.url)
                .onSuccess { _, _, _ in
                }
                .resizable()
                .indicator(.activity)

            Button(action: {}) {
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .foregroundColor(.secondary)

                    Image(systemName: "arrow.clockwise.circle") // TODO: button icon
                        .font(Font.system(size: 32, weight: .semibold))
                }
                .frame(width: 48, height: 48)
                .opacity(buttonOpacity)
                .onHover { hovering in
                    buttonOpacity = hovering ? 0.8 : 0.2
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
    }

    // MARK: - Draw Constants

    private let cornerRadius: CGFloat = 8
}

struct PreviewView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewView(of: nil)
            .previewLayout(.sizeThatFits)
    }
}
