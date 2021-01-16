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

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                // Preference button
                ImageButton(image: {
                    Image(systemName: "gearshape")
                        .font(Font.system(size: buttonIconSize, weight: .bold))
                }) {
                    withAnimation(.easeInOut) {
                        currentView = .preference
                    }
                }

                // History button
                ImageButton(image: {
                    Image(systemName: "clock")
                        .font(Font.system(size: buttonIconSize, weight: .bold))
                }) {
                    withAnimation(.easeInOut) {
                        currentView = .history
                    }
                }

                Spacer()

                if fetcher.isDownloading {
                    ProgressView(value: fetcher.downloadingProgress)
                        .frame(width: downloadProgressIndicator)
                }

                // Download button
                ImageButton(image: {
                    Group {
                        fetcher.isDownloading ? Image(systemName: "xmark") : Image(systemName: "square.and.arrow.down")
                    }
                    .font(Font.system(size: buttonIconSize, weight: .bold))
                }) {
                    if fetcher.isDownloading {
                        fetcher.cancelDownload()
                    } else if let directory = try? FileManager.default.url(for: .downloadsDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
                        fetcher.download(to: directory) { url in
                            // TODO: send notification
                            print(url)
                        }
                    }
                }
                .disabled(fetcher.isLoading)
            }
            .padding(buttonPaddingLength)

            ImageView()
                .environmentObject(fetcher)
                .aspectRatio(previewImageAspectRatio, contentMode: .fit)

            CapsuleButton("Set as Wallpaper") { // TODO: localization
                fetcher.setWallpaper()
            }
            .padding(2 * buttonPaddingLength)
            .disabled(fetcher.isLoading)
        }
    }

    // MARK: - Draw Constants

    private let previewImageAspectRatio: CGFloat = 1.6
    private let buttonIconSize: CGFloat = 16
    private let buttonPaddingLength: CGFloat = 6
    private let downloadProgressIndicator: CGFloat = 60
}

struct PreviewView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PersistenceController().container.viewContext
        let fetcher = WallpaperFetcher(in: viewContext)

        PreviewView(currentView: .constant(.preview))
            .environment(\.managedObjectContext, viewContext)
            .environmentObject(fetcher)
            .frame(width: 400)
    }
}
