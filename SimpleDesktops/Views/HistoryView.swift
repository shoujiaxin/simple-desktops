//
//  HistoryView.swift
//  Simple Desktops
//
//  Created by Jiaxin Shou on 2021/1/15.
//

import Kingfisher
import SwiftUI

struct HistoryView: View {
    @Binding var currentView: PopoverView.ViewState

    @Environment(\.managedObjectContext) private var viewContext: NSManagedObjectContext

    @EnvironmentObject private var fetcher: PictureFetcher

    @FetchRequest(fetchRequest: Picture.fetchRequest(nil)) private var pictures: FetchedResults<Picture>

    @State private var hoveringItem: Picture?

    // MARK: Views

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(buttonPaddingLength)

            ScrollView {
                Spacer(minLength: highlighStrokeWidth)

                LazyVGrid(columns: Array(repeating: GridItem(.fixed(pictureWidth), spacing: pictureSpacing), count: 2)) {
                    ForEach(pictures) { picture in
                        KFImage(picture.previewURL)
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
                            // FIXME: Memory leak (don't know why, seems like a bug in SwiftUI when having a contextMenu)
                            .contextMenu {
                                // Download button
                                Button {
                                    fetcher.download(picture) { url in
                                        UserNotification.shared.request(title: "Picture Downloaded", body: url.lastPathComponent, attachmentURLs: [picture.previewURL])
                                    }
                                } label: {
                                    Text("Download")
                                }
                                .keyboardShortcut("d")

                                // Set wallpaper button
                                Button {
                                    fetcher.download(picture, to: WallpaperManager.directory) { url in
                                        WallpaperManager.shared.setWallpaper(with: url)
                                        UserNotification.shared.request(title: "Wallpaper Changed", body: url.lastPathComponent, attachmentURLs: [picture.previewURL])
                                    }
                                } label: {
                                    Text("Set as wallpaper")
                                }

                                Divider()

                                // Delete button
                                Button {
                                    withAnimation(.easeInOut) {
                                        viewContext.delete(picture)
                                        try? viewContext.save()
                                    }
                                } label: {
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

    private var header: some View {
        HStack {
            Button(action: transitToPreview) {
                Image(systemName: "chevron.backward")
                    .font(Font.system(size: buttonIconSize, weight: .bold))
            }
            .buttonStyle(ImageButtonStyle())

            Spacer()

            if fetcher.isDownloading {
                ProgressView(value: fetcher.downloadingProgress)
                    .frame(width: downloadProgressIndicator)

                Button(action: { fetcher.cancelDownload() }) {
                    Image(systemName: "xmark")
                        .font(Font.system(size: buttonIconSize, weight: .bold))
                }
                .buttonStyle(ImageButtonStyle())
            }
        }
    }

    // MARK: - Funstions

    private func transitToPreview() {
        withAnimation(.easeInOut) {
            currentView = .preview
        }
    }

    // MARK: - Constants

    private let buttonIconSize: CGFloat = 16
    private let buttonPaddingLength: CGFloat = 6
    private let downloadProgressIndicator: CGFloat = 60
    private let highlighStrokeWidth: CGFloat = 6
    private let pictureAspectRatio: CGFloat = 1.6
    private let pictureWidth: CGFloat = 176
    private let pictureSpacing: CGFloat = 16
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
