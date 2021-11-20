//
//  PopoverView.swift
//  SimpleDesktops
//
//  Created by Jiaxin Shou on 2021/1/14.
//

import SwiftUI

struct PopoverView: View {
    enum ViewState {
        case preview
        case preference
        case history

        var height: CGFloat {
            switch self {
            case .preference:
                return smallPopoverHeight
            case .preview,
                 .history:
                return largePopoverHeight
            }
        }
    }

    @EnvironmentObject private var service: PictureService

    @FetchRequest(fetchRequest: Picture
        .fetchRequest(nil)) private var pictures: FetchedResults<Picture>

    @State private var currentView: ViewState = .preview

    // MARK: - Views

    var body: some View {
        VStack(spacing: 0) {
            if currentView != .preference {
                navigationBar
            }

            content()
        }
        .frame(width: popoverWidth, height: currentView.height)
        .onReceive(WallpaperManager.shared.autoChangePublisher) { _ in
            Task {
                await service.fetch()
                if let picture = pictures.first {
                    service.setWallpaper(picture)
                }
            }
        }
    }

    private var navigationBar: some View {
        HStack {
            if currentView == .preview {
                // Preference button
                Button(action: transitToPreferenceView) {
                    Image(systemName: "gearshape")
                        .font(Font.system(size: navigationBarButtonIconSize, weight: .bold))
                }

                // History button
                Button(action: transitToHistoryView) {
                    Image(systemName: "clock")
                        .font(Font.system(size: navigationBarButtonIconSize, weight: .bold))
                }
            } else if currentView == .history {
                // Back to preview button
                Button(action: transitToPreviewView) {
                    Image(systemName: "chevron.backward")
                        .font(Font.system(size: navigationBarButtonIconSize, weight: .bold))
                }
            }

            Spacer()

            if service.isDownloading {
                // Download progress indicator
                ProgressView(value: service.downloadingProgress)
                    .frame(width: downloadProgressIndicatorWidth)

                // Cancel download button
                Button(action: service.cancelDownload) {
                    Image(systemName: "xmark")
                        .font(Font.system(size: navigationBarButtonIconSize, weight: .bold))
                }
            } else if currentView == .preview {
                // Delete button
                Button {
                    if let picture = pictures.first {
                        service.delete(picture)
                    }
                } label: {
                    Image(systemName: "trash")
                        .font(Font.system(size: navigationBarButtonIconSize, weight: .bold))
                }
                .disabled(service.isFetching)

                // Download button
                Button {
                    if let picture = pictures.first {
                        service.download(picture) { url in
                            try? await UserNotification.request(
                                title: "Picture Downloaded",
                                body: url.lastPathComponent,
                                attachmentURLs: [picture.previewURL]
                            )
                        }
                    }
                } label: {
                    Image(systemName: "square.and.arrow.down")
                        .font(Font.system(size: navigationBarButtonIconSize, weight: .bold))
                }
                .disabled(service.isFetching)
            }
        }
        .buttonStyle(ImageButtonStyle())
        .padding(navigationBarPadding)
    }

    @ViewBuilder
    private func content() -> some View {
        switch currentView {
        case .preview:
            PreviewView(picture: pictures.first)

        case .preference:
            PreferenceView(currentView: $currentView)
                .transition(.move(edge: .bottom))

        case .history:
            HistoryView(pictures: pictures.map { $0 })
                .transition(.move(edge: .trailing))
        }
    }

    // MARK: - Functions

    private func transitToPreviewView() {
        withAnimation(.easeInOut) {
            currentView = .preview
        }
    }

    private func transitToPreferenceView() {
        withAnimation(.easeInOut) {
            currentView = .preference
        }
    }

    private func transitToHistoryView() {
        withAnimation(.easeInOut) {
            currentView = .history
        }
    }

    // MARK: - Constants

    private static let smallPopoverHeight: CGFloat = 195
    private static let largePopoverHeight: CGFloat = 358
    private let popoverWidth: CGFloat = 400
    private let navigationBarButtonIconSize: CGFloat = 16
    private let downloadProgressIndicatorWidth: CGFloat = 60
    private let navigationBarPadding: CGFloat = 6
}

struct PopoverView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PersistenceController.preview.container.viewContext
        PopoverView()
            .environment(\.managedObjectContext, viewContext)
            .environmentObject(PictureService(context: viewContext))
    }
}
