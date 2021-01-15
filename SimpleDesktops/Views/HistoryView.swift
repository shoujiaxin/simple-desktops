//
//  HistoryView.swift
//  Simple Desktops
//
//  Created by Jiaxin Shou on 2021/1/15.
//

import SDWebImageSwiftUI
import SwiftUI

struct HistoryView: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme

    @FetchRequest(fetchRequest: Wallpaper.fetchRequest(.all)) var wallpapers: FetchedResults<Wallpaper>

    @Binding var currentView: PopoverView.ViewState

    @State private var hoveringItem: Wallpaper?

    var body: some View {
        VStack {
            HStack {
                backButton
                    .padding(imageButtonPadding)
                    .font(Font.system(size: imageButtonSize, weight: .bold))
                    .buttonStyle(PlainButtonStyle())

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

                            WebImage(url: wallpaper.previewUrl)
                                .resizable()
                                .aspectRatio(historyImageAspectRatio, contentMode: .fill)
                                .onHover { _ in
                                    self.hoveringItem = wallpaper
                                }
                        }
                    }
                }

                Spacer(minLength: highlighLineWidth)
            }
        }
    }

    private var backButton: some View {
        Button(action: {
            withAnimation(.easeInOut) {
                currentView = .preview
            }
        }) {
            Image(systemName: "chevron.backward")
        }
    }

    // MARK: - Draw Constants

    private let historyImageWidth: CGFloat = 176
    private let historyImageAspectRatio: CGFloat = 1.6
    private let historyImageSpacing: CGFloat = 16
    private let imageButtonSize: CGFloat = 16
    private let imageButtonPadding: CGFloat = 12
    private let highlighLineWidth: CGFloat = 6
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PersistenceController().container.viewContext

        HistoryView(currentView: .constant(.history))
            .environment(\.managedObjectContext, viewContext)
            .previewLayout(.fixed(width: 400, height: 358))
    }
}
