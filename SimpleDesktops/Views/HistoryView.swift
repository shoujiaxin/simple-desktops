//
//  HistoryView.swift
//  Simple Desktops
//
//  Created by Jiaxin Shou on 2021/1/15.
//

import SDWebImageSwiftUI
import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var fetcher: WallpaperFetcher

    @FetchRequest(fetchRequest: Wallpaper.fetchRequest(nil)) var wallpapers: FetchedResults<Wallpaper>

    @Binding var currentView: PopoverView.ViewState

    @State private var hoveringItem: Wallpaper?

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                ImageButton(image: {
                    Image(systemName: "chevron.backward")
                        .font(Font.system(size: buttonIconSize, weight: .bold))
                }) {
                    withAnimation(.easeInOut) {
                        currentView = .preview
                    }
                }
                .padding(buttonPaddingLength)

                Spacer()
            }

            ScrollView {
                Spacer(minLength: highlighLineWidth)

                LazyVGrid(columns: Array(repeating: GridItem(.fixed(historyImageWidth), spacing: historyImageSpacing), count: 2)) {
                    ForEach(wallpapers) { wallpaper in
                        ZStack {
                            Rectangle()
                                .stroke(lineWidth: hoveringItem == wallpaper ? highlighLineWidth : 0)
                                .foregroundColor(.accentColor)

                            WebImage(url: wallpaper.previewURL)
                                .resizable()
                                .aspectRatio(historyImageAspectRatio, contentMode: .fill)
                                .onHover { _ in
                                    self.hoveringItem = wallpaper
                                }
                        }
                        .contextMenu {
                            // Download button
                            Button(action: {
                                if let directory = try? FileManager.default.url(for: .downloadsDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
                                    fetcher.download(wallpaper, to: directory)
                                }
                            }) {
                                Text("Download")
                            }
                            .keyboardShortcut("d")

                            // Set as wallpaper button
                            Button(action: {
                                fetcher.setWallpaper(wallpaper)
                            }) {
                                Text("Set as wallpaper")
                            }

                            Divider()

                            // Delete button
                            Button(action: {
                                fetcher.deleteWallpaper(wallpaper)
                            }) {
                                Text("Delete")
                            }
                            .keyboardShortcut(.delete)
                        }
                    }
                }

                Spacer(minLength: highlighLineWidth)
            }
        }
    }

    // MARK: - Draw Constants

    private let historyImageWidth: CGFloat = 176
    private let historyImageAspectRatio: CGFloat = 1.6
    private let historyImageSpacing: CGFloat = 16
    private let buttonIconSize: CGFloat = 16
    private let buttonPaddingLength: CGFloat = 6
    private let highlighLineWidth: CGFloat = 6
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PersistenceController().container.viewContext

        HistoryView(currentView: .constant(.history))
            .environment(\.managedObjectContext, viewContext)
            .frame(width: 400, height: 358)
    }
}
