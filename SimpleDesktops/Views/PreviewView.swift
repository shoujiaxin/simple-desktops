//
//  PreviewView.swift
//  Simple Desktops
//
//  Created by Jiaxin Shou on 2021/1/14.
//

import SwiftUI

struct PreviewView: View {
    @EnvironmentObject var fetcher: WallpaperFetcher

    // MARK: - States

    @State private var buttonOpacity: Double = 0.2

    // MARK: - Views

    var body: some View {
        ZStack {
            if let image = fetcher.image {
                Image(nsImage: image)
                    .resizable()
            } else {
                Rectangle() // Placeholder
                    .foregroundColor(.clear)
            }

            if !fetcher.isLoading {
                button
            }
        }
        .onAppear {
            buttonOpacity = buttonIdleOpacity
        }
    }

    private var button: some View {
        Button(action: {
            fetcher.fetchURL()
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .foregroundColor(.secondary)

                Image(systemName: "arrow.clockwise.circle") // TODO: button icon
                    .font(Font.system(size: buttonIconSize, weight: .semibold))
            }
            .frame(width: buttonSize, height: buttonSize)
            .opacity(buttonOpacity)
            .onHover { hovering in
                buttonOpacity = hovering ? buttonHoveringOpacity : buttonIdleOpacity
            }
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Draw Constants

    private let cornerRadius: CGFloat = 8
    private let buttonIconSize: CGFloat = 32
    private let buttonSize: CGFloat = 48
    private let buttonHoveringOpacity: Double = 0.8
    private let buttonIdleOpacity: Double = 0.2
}

struct PreviewView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PersistenceController().container.viewContext
        let fetcher = WallpaperFetcher(in: viewContext)

        PreviewView()
            .environmentObject(fetcher)
            .previewLayout(.sizeThatFits)
    }
}
