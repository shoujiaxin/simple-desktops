//
//  PreviewView.swift
//  Simple Desktops
//
//  Created by Jiaxin Shou on 2021/1/14.
//

import SDWebImageSwiftUI
import SwiftUI

struct PreviewView: View {
    @ObservedObject var fetcher: WallpaperFetcher

    // MARK: - States

    @State private var buttonOpacity: Double = 0.2
    @State private var isLoading: Bool = false

    // MARK: - Views

    var body: some View {
        ZStack {
            WebImage(url: fetcher.imageUrl)
                .onSuccess { _, _, _ in
                    isLoading = false // TODO: runtime warning
                }
                .onFailure { _ in
                    isLoading = false // TODO: runtime warning
                }
                .resizable()
                .indicator(.progress)

            if !isLoading {
                button
            }
        }
    }

    private var button: some View {
        Button(action: {
            isLoading = true
            fetcher.fetchURL()
        }) {
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

    // MARK: - Draw Constants

    private let cornerRadius: CGFloat = 8
}

struct PreviewView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewView(fetcher: WallpaperFetcher(in: PersistenceController.shared.container.viewContext))
            .previewLayout(.sizeThatFits)
    }
}
