//
//  PreviewView.swift
//  Simple Desktops
//
//  Created by Jiaxin Shou on 2021/1/15.
//

import SDWebImageSwiftUI
import SwiftUI

struct PreviewView: View {
    @Binding var currentView: PopoverView.ViewState

    @Environment(\.colorScheme) private var colorScheme: ColorScheme

    @EnvironmentObject private var fetcher: PictureFetcher

    @FetchRequest(fetchRequest: Picture.fetchRequest(nil, fetchLimit: 1)) private var pictures: FetchedResults<Picture>

    @State private var buttonHovering: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Group {
                    // Preference button
                    Button(action: {
                        withAnimation(.easeInOut) {
                            currentView = .preference
                        }
                    }) {
                        Image(systemName: "gearshape")
                            .font(Font.system(size: buttonIconSize, weight: .bold))
                    }

                    // History button
                    Button(action: {
                        withAnimation(.easeInOut) {
                            currentView = .history
                        }
                    }) {
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
                Button(action: {
                    if fetcher.isDownloading {
                        fetcher.cancelDownload()
                    } else if let picture = pictures.first {
                        fetcher.download(picture) { url in
                            UserNotification.shared.request(title: "Picture Downloaded", body: url.lastPathComponent, attachmentURLs: [url])
                        }
                    }
                }) {
                    Image(systemName: fetcher.isDownloading ? "xmark" : "square.and.arrow.down")
                        .font(Font.system(size: buttonIconSize, weight: .bold))
                }
                .buttonStyle(ImageButtonStyle())
                .disabled(fetcher.isFetching)
            }
            .padding(buttonPaddingLength)

            ZStack {
                WebImage(url: pictures.first?.previewURL)
                    .resizable()
                    .aspectRatio(pictureAspectRatio, contentMode: .fit)

                if fetcher.isFetching {
                    ProgressView(value: fetcher.fetchingProgress)
                        .progressViewStyle(CircularProgressViewStyle())
                } else {
                    fetchButton
                }
            }

            Button(action: {
                if let picture = pictures.first {
                    fetcher.download(picture, to: WallpaperManager.directory) { url in
                        WallpaperManager.shared.setWallpaper(with: url)
                        UserNotification.shared.request(title: "Wallpaper Changed", body: url.lastPathComponent, attachmentURLs: [url])
                    }
                }
            }) {
                Text("Set as Wallpaper")
            }
            .buttonStyle(CapsuledButtonStyle())
            .padding(buttonPaddingLength * 2.0)
            .disabled(fetcher.isFetching)
        }
    }

    private var fetchButton: some View {
        Button(action: {
            fetcher.fetch()
        }) {
            Image(systemName: "arrow.triangle.2.circlepath")
                .font(Font.system(size: buttonIconSize * 2.0, weight: .bold))
                .frame(width: 48, height: 48, alignment: .center)
                .foregroundColor(colorScheme == .dark ? .black : .white)
                .background(RoundedRectangle(cornerRadius: 8.0))
                .opacity(buttonHovering ? 0.8 : 0.2)
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

    // MARK: - Draw Constants

    private let buttonIconSize: CGFloat = 16.0
    private let buttonPaddingLength: CGFloat = 6.0
    private let downloadProgressIndicator: CGFloat = 60.0
    private let pictureAspectRatio: CGFloat = 1.6
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
