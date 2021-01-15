//
//  PreviewView.swift
//  Simple Desktops
//
//  Created by Jiaxin Shou on 2021/1/15.
//

import SwiftUI

struct PreviewView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @EnvironmentObject var fetcher: WallpaperFetcher

    @Binding var currentView: PopoverView.ViewState

    // MARK: - Views

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                preferencesButton
                    .padding(imageButtonPadding)

                historyButton
                    .padding(imageButtonPadding)

                Spacer()

                if fetcher.isDownloading {
                    ProgressView(value: fetcher.downloadingProgress)
                        .frame(width: downloadProgressIndicator)
                }

                downloadButton
                    .padding(imageButtonPadding)
                    .disabled(fetcher.isLoading)
            }

            ImageView()
                .environmentObject(fetcher)
                .aspectRatio(previewImageAspectRatio, contentMode: .fill)

            setWallpaperButon
                .frame(width: capsuleButtonWidth, height: capsuleButtonHeight)
                .padding(2 * imageButtonPadding)
                .disabled(fetcher.isLoading)
        }
    }

    private var preferencesButton: some View {
        Button(action: {
            withAnimation(.easeInOut) {
                currentView = .preference
            }
        }) {
            Image(systemName: "gearshape")
                .font(Font.system(size: imageButtonIconSize, weight: .bold))
                .frame(width: imageButtonSize, height: imageButtonSize)
                .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var historyButton: some View {
        Button(action: {
            withAnimation(.easeInOut) {
                currentView = .history
            }
        }) {
            Image(systemName: "clock")
                .font(Font.system(size: imageButtonIconSize, weight: .bold))
                .frame(width: imageButtonSize, height: imageButtonSize)
                .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var downloadButton: some View {
        Button(action: {
            fetcher.isDownloading ? fetcher.cancelDownload() : fetcher.download()
        }) {
            Group {
                fetcher.isDownloading ? Image(systemName: "xmark") : Image(systemName: "square.and.arrow.down")
            }
            .font(Font.system(size: imageButtonIconSize, weight: .bold))
            .frame(width: imageButtonSize, height: imageButtonSize)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var setWallpaperButon: some View {
        Button(action: {
            // TODO: set as wallpaper
        }) {
            ZStack {
                // TODO: Button color
                Capsule()
                    .stroke(lineWidth: 2.0)

                Text("Set as Wallpaper")
                    .frame(width: capsuleButtonWidth, height: capsuleButtonHeight)
                    .contentShape(Capsule())
            }
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Draw Constants

    private let previewImageAspectRatio: CGFloat = 1.6
    private let imageButtonIconSize: CGFloat = 16
    private let imageButtonSize: CGFloat = 32
    private let imageButtonPadding: CGFloat = 6
    private let downloadProgressIndicator: CGFloat = 60
    private let capsuleButtonWidth: CGFloat = 240
    private let capsuleButtonHeight: CGFloat = 40
}

struct PreviewView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PersistenceController().container.viewContext
        let fetcher = WallpaperFetcher(in: viewContext)

        PreviewView(currentView: .constant(.preview))
            .environment(\.managedObjectContext, viewContext)
            .environmentObject(fetcher)
            .previewLayout(.sizeThatFits)
    }
}
