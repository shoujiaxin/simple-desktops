//
//  HistoryView.swift
//  Simple Desktops
//
//  Created by Jiaxin Shou on 2021/1/15.
//

import SDWebImageSwiftUI
import SwiftUI

struct HistoryView: View {
    @Binding var currentView: PopoverView.ViewState

    @Environment(\.managedObjectContext) private var viewContext: NSManagedObjectContext

    @EnvironmentObject private var fetcher: PictureFetcher

    @FetchRequest(fetchRequest: Picture.fetchRequest(nil)) private var pictures: FetchedResults<Picture>

    @State private var hoveringItem: Picture?

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: {
                    withAnimation(.easeInOut) {
                        currentView = .preview
                    }
                }) {
                    Image(systemName: "chevron.backward")
                        .font(Font.system(size: buttonIconSize, weight: .bold))
                }
                .buttonStyle(ImageButtonStyle())

                Spacer()

                if fetcher.isDownloading {
                    ProgressView(value: fetcher.downloadingProgress)
                        .frame(width: downloadProgressIndicator)

                    Button(action: {
                        fetcher.cancelDownload()
                    }) {
                        Image(systemName: "xmark")
                            .font(Font.system(size: buttonIconSize, weight: .bold))
                    }
                    .buttonStyle(ImageButtonStyle())
                }
            }
            .padding(buttonPaddingLength)

            ScrollView {
                Spacer(minLength: highlighStrokeWidth)

                LazyVGrid(columns: Array(repeating: GridItem(.fixed(pictureWidth), spacing: pictureSpacing), count: 2)) {
                    ForEach(pictures) { picture in
                        WebImage(url: picture.previewURL)
                            .resizable()
                            .aspectRatio(pictureAspectRatio, contentMode: .fit)
                            .background(
                                Rectangle()
                                    .stroke(lineWidth: hoveringItem == picture ? highlighStrokeWidth : 0)
                                    .foregroundColor(.accentColor)
                            )
                            .onHover { hovering in
                                self.hoveringItem = hovering ? picture : nil
                            }
                            .contextMenu {
                                // Download Button
                                Button(action: {
                                    fetcher.download(picture) { url in
                                        UserNotification.shared.request(title: "Picture Downloaded", body: url.lastPathComponent, attachmentURLs: [url])
                                    }
                                }) {
                                    Text("Download")
                                }
                                .keyboardShortcut("d")

                                // Set Wallpaper Button
                                Button(action: {
                                    fetcher.download(picture, to: WallpaperManager.shared.directory) { url in
                                        WallpaperManager.shared.setWallpaper(with: url)
                                        UserNotification.shared.request(title: "Wallpaper Changed", body: url.lastPathComponent, attachmentURLs: [url])
                                    }
                                }) {
                                    Text("Set as wallpaper")
                                }

                                Divider()

                                // Delete Button
                                Button(action: {
                                    viewContext.delete(picture)
                                    try? viewContext.save()
                                }) {
                                    Text("Delete")
                                }
                                .keyboardShortcut(.delete)
                            }
                    }
                }

                Spacer(minLength: highlighStrokeWidth)
            }
        }
    }

    // MARK: - Draw Constants

    private let buttonIconSize: CGFloat = 16.0
    private let buttonPaddingLength: CGFloat = 6.0
    private let downloadProgressIndicator: CGFloat = 60.0
    private let highlighStrokeWidth: CGFloat = 6.0
    private let pictureAspectRatio: CGFloat = 1.6
    private let pictureWidth: CGFloat = 176.0
    private let pictureSpacing: CGFloat = 16.0
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PersistenceController.preview.container.viewContext
        HistoryView(currentView: .constant(.history))
            .environment(\.managedObjectContext, viewContext)
            .environmentObject(PictureFetcher(context: viewContext))
            .frame(width: 400, height: 358)
    }
}
