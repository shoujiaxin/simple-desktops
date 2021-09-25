//
//  PreviewView.swift
//  Simple Desktops
//
//  Created by Jiaxin Shou on 2021/1/15.
//

import Kingfisher
import SwiftUI

struct PreviewView: View {
    @Binding var currentView: PopoverView.ViewState

    @Environment(\.colorScheme) private var colorScheme: ColorScheme

    @EnvironmentObject private var fetcher: PictureFetcher

    @FetchRequest(fetchRequest: Picture.fetchRequest(nil, fetchLimit: 1)) private var pictures: FetchedResults<Picture>

    @State private var buttonHovering: Bool = false

    // MARK: Views

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(headerPadding)

            ZStack {
                KFImage(pictures.first?.previewURL)
                    .resizable()
                    .aspectRatio(pictureAspectRatio, contentMode: .fit)

                if fetcher.isFetching {
                    ProgressView(value: fetcher.fetchingProgress)
                        .progressViewStyle(CircularProgressViewStyle())
                } else {
                    fetchButton
                }
            }

            Button(action: setWallpaper) {
                Text("Set as Wallpaper")
            }
            .buttonStyle(CapsuledButtonStyle())
            .padding(setWallpaperButtonPadding)
            .disabled(fetcher.isFetching)
        }
    }

    private var header: some View {
        HStack {
            Group {
                // Preference button
                Button(action: transitToPreference) {
                    Image(systemName: "gearshape")
                        .font(Font.system(size: buttonIconSize, weight: .bold))
                }

                // History button
                Button(action: transitToHistory) {
                    Image(systemName: "clock")
                        .font(Font.system(size: buttonIconSize, weight: .bold))
                }
            }
            .buttonStyle(ImageButtonStyle())

            Spacer()

            if fetcher.isDownloading {
                ProgressView(value: fetcher.downloadingProgress)
                    .frame(width: downloadProgressIndicator)
            }

            // Download button
            Button(action: onDownloadButtonClick) {
                Image(systemName: fetcher.isDownloading ? "xmark" : "square.and.arrow.down")
                    .font(Font.system(size: buttonIconSize, weight: .bold))
            }
            .buttonStyle(ImageButtonStyle())
            .disabled(fetcher.isFetching)
        }
    }

    private var fetchButton: some View {
        Button { fetcher.fetch() } label: {
            Image(systemName: "arrow.triangle.2.circlepath")
                .font(Font.system(size: fetchButtonIconSize, weight: .bold))
                .frame(width: fetchButtonFrameSize, height: fetchButtonFrameSize, alignment: .center)
                .foregroundColor(colorScheme == .dark ? .black : .white)
                .background(RoundedRectangle(cornerRadius: fetchButtonCornerRadius))
                .opacity(buttonHovering ? fetchButtonHoveringOpacity : fetchButtonNotHoveringOpacity)
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            buttonHovering = hovering
        }
        .onReceive(WallpaperManager.shared.autoChangePublisher) { _ in
            fetcher.fetch { picture in
                fetcher.download(picture, to: WallpaperManager.directory) { url in
                    WallpaperManager.shared.setWallpaper(with: url)
                    UserNotification.shared.request(title: "Wallpaper Changed", body: url.lastPathComponent, attachmentURLs: [url])
                }
            }
        }
    }

    // MARK: - Funstions

    private func transitToPreference() {
        withAnimation(.easeInOut) {
            currentView = .preference
        }
    }

    private func transitToHistory() {
        withAnimation(.easeInOut) {
            currentView = .history
        }
    }

    private func onDownloadButtonClick() {
        if fetcher.isDownloading {
            fetcher.cancelDownload()
        } else if let picture = pictures.first {
            fetcher.download(picture) { url in
                UserNotification.shared.request(title: "Picture Downloaded", body: url.lastPathComponent, attachmentURLs: [url])
            }
        }
    }

    private func setWallpaper() {
        guard let picture = pictures.first else {
            return
        }

        fetcher.download(picture, to: WallpaperManager.directory) { url in
            WallpaperManager.shared.setWallpaper(with: url)
            UserNotification.shared.request(title: "Wallpaper Changed", body: url.lastPathComponent, attachmentURLs: [url])
        }
    }

    // MARK: - Constants

    private let headerPadding: CGFloat = 6
    private let buttonIconSize: CGFloat = 16
    private let setWallpaperButtonPadding: CGFloat = 12
    private let downloadProgressIndicator: CGFloat = 60
    private let pictureAspectRatio: CGFloat = 1.6
    private let fetchButtonIconSize: CGFloat = 32
    private let fetchButtonFrameSize: CGFloat = 48
    private let fetchButtonCornerRadius: CGFloat = 8
    private let fetchButtonHoveringOpacity: Double = 0.8
    private let fetchButtonNotHoveringOpacity: Double = 0.2
}

struct PreviewView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PersistenceController.preview.container.viewContext
        PreviewView(currentView: .constant(.preview))
            .environment(\.managedObjectContext, viewContext)
            .environmentObject(PictureFetcher(context: viewContext))
            .frame(width: 400)
    }
}
