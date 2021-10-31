//
//  HistoryView.swift
//  SimpleDesktops
//
//  Created by Jiaxin Shou on 2021/1/15.
//

import Kingfisher
import SwiftUI

struct HistoryView: View {
    @Environment(\.managedObjectContext) private var viewContext: NSManagedObjectContext

    @EnvironmentObject private var service: PictureService

    @FetchRequest(fetchRequest: Picture.fetchRequest(nil)) private var pictures: FetchedResults<Picture>

    @State private var hoveringItem: Picture?

    var body: some View {
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
                        .contextMenu {
                            // Download button
                            Button {
                                service.download(picture) { url in
                                    UserNotification.shared.request(title: "Picture Downloaded", body: url.lastPathComponent, attachmentURLs: [picture.previewURL])
                                }
                            } label: {
                                Text("Download")
                            }
                            .keyboardShortcut("d")

                            // Set wallpaper button
                            Button {
                                service.download(picture, to: WallpaperManager.directory) { url in
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

    // MARK: - Constants

    private let highlighStrokeWidth: CGFloat = 6
    private let pictureAspectRatio: CGFloat = 1.6
    private let pictureWidth: CGFloat = 176
    private let pictureSpacing: CGFloat = 16
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PersistenceController.preview.container.viewContext
        HistoryView()
            .environment(\.managedObjectContext, viewContext)
            .environmentObject(PictureService(context: viewContext))
            .frame(width: 400, height: 314)
    }
}
