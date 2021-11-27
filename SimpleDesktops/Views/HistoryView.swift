//
//  HistoryView.swift
//  SimpleDesktops
//
//  Created by Jiaxin Shou on 2021/1/15.
//

import Kingfisher
import SwiftUI

struct HistoryView: View {
    @EnvironmentObject private var service: PictureService

    @State private var hoveringItem: Picture?

    let pictures: [Picture]

    var body: some View {
        ScrollView {
            Spacer(minLength: highlighStrokeWidth)

            LazyVGrid(columns: Array(repeating: GridItem(.fixed(pictureWidth),
                                                         spacing: pictureSpacing), count: 2)) {
                ForEach(pictures) { picture in
                    KFImage(picture.previewURL)
                        .resizable()
                        .aspectRatio(pictureAspectRatio, contentMode: .fit)
                        .border(
                            Color.accentColor,
                            width: hoveringItem == picture ? highlighStrokeWidth : 0
                        )
                        .onHover { isHovering in
                            hoveringItem = isHovering ? picture : nil
                        }
                        .contextMenu {
                            // Download button
                            Button {
                                service.download(picture) { url in
                                    try? await UserNotification.request(
                                        title: "Picture Downloaded",
                                        body: url.lastPathComponent,
                                        attachmentURLs: [picture.previewURL]
                                    )
                                }
                            } label: {
                                Text("Download")
                            }
                            .keyboardShortcut("d")

                            // Set wallpaper button
                            Button {
                                service.setWallpaper(picture)
                            } label: {
                                Text("Set as wallpaper")
                            }

                            Divider()

                            // Delete button
                            Button {
                                service.delete(picture)
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

    private let highlighStrokeWidth: CGFloat = 3
    private let pictureAspectRatio: CGFloat = 1.6
    private let pictureWidth: CGFloat = 176
    private let pictureSpacing: CGFloat = 16
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PersistenceController.preview.container.viewContext
        let pictures = try! viewContext.fetch(Picture.fetchRequest(nil))
        HistoryView(pictures: pictures)
            .environmentObject(PictureService(context: viewContext))
            .frame(width: 400, height: 314)
    }
}
