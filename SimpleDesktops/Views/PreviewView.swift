//
//  PreviewView.swift
//  SimpleDesktops
//
//  Created by Jiaxin Shou on 2021/1/15.
//

import Kingfisher
import SwiftUI

struct PreviewView: View {
    @Binding var currentView: PopoverView.ViewState

    @Environment(\.colorScheme) private var colorScheme: ColorScheme

    @EnvironmentObject private var service: PictureService

    @FetchRequest(fetchRequest: Picture.fetchRequest(nil, fetchLimit: 1)) private var pictures: FetchedResults<Picture>

    @State private var buttonHovering: Bool = false

    // MARK: - Views

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(headerPadding)

            ZStack {
                if let image = service.previewImage {
                    Image(nsImage: image)
                        .resizable()
                        .aspectRatio(pictureAspectRatio, contentMode: .fit)
                } else {
                    Rectangle()
                        .foregroundColor(.clear)
                }

                if service.isFetching {
                    ProgressView(value: service.fetchingProgress)
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
            .disabled(service.isFetching || service.isDownloading)
        }
        .onReceive(WallpaperManager.shared.autoChangePublisher) { _ in
            Task {
                await service.fetch()
                setWallpaper()
            }
        }
    }

    private var header: some View {
        HStack {
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

            Spacer()

            if service.isDownloading {
                ProgressView(value: service.downloadingProgress)
                    .frame(width: downloadProgressIndicatorWidth)
            }

            // Download button
            Button(action: onDownloadButtonClick) {
                Image(systemName: service.isDownloading ? "xmark" : "square.and.arrow.down")
                    .font(Font.system(size: buttonIconSize, weight: .bold))
            }
            .disabled(service.isFetching)
        }
        .buttonStyle(ImageButtonStyle())
    }

    private var fetchButton: some View {
        Button {
            Task {
                await service.fetch()
            }
        } label: {
            Image(systemName: "arrow.triangle.2.circlepath")
                .font(Font.system(size: fetchButtonIconSize, weight: .bold))
                .frame(width: fetchButtonFrameSize, height: fetchButtonFrameSize, alignment: .center)
                .foregroundColor(colorScheme == .dark ? .black : .white)
                .background(RoundedRectangle(cornerRadius: fetchButtonCornerRadius))
                .opacity(buttonHovering ? fetchButtonHoveringOpacity : fetchButtonNormalOpacity)
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            buttonHovering = hovering
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
        if service.isDownloading {
            service.cancelDownload()
        } else if let picture = pictures.first {
            service.download(picture)
        }
    }

    private func setWallpaper() {
        guard let picture = pictures.first else {
            return
        }

        service.download(picture, to: WallpaperManager.directory) { url in
            WallpaperManager.shared.setWallpaper(with: url)
            UserNotification.shared.request(title: "Wallpaper Changed", body: url.lastPathComponent, attachmentURLs: [picture.previewURL])
        }
    }

    // MARK: - Constants

    private let headerPadding: CGFloat = 6
    private let buttonIconSize: CGFloat = 16
    private let setWallpaperButtonPadding: CGFloat = 12
    private let downloadProgressIndicatorWidth: CGFloat = 60
    private let pictureAspectRatio: CGFloat = 1.6
    private let fetchButtonIconSize: CGFloat = 32
    private let fetchButtonFrameSize: CGFloat = 48
    private let fetchButtonCornerRadius: CGFloat = 8
    private let fetchButtonHoveringOpacity: Double = 0.8
    private let fetchButtonNormalOpacity: Double = 0.2
}

struct PreviewView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewView(currentView: .constant(.preview))
            .environmentObject(PictureService(context: PersistenceController.preview.container.viewContext))
            .frame(width: 400)
    }
}
