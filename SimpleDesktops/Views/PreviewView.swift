//
//  PreviewView.swift
//  Simple Desktops
//
//  Created by Jiaxin Shou on 2021/1/15.
//

import SwiftUI

struct PreviewView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @EnvironmentObject var fetcher: WallpaperFetcher

    @Binding var currentView: PopoverView.ViewState

    // MARK: - Views

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Group {
                    preferencesButton

                    historyButton

                    Spacer()

                    if fetcher.isDownloading {
                        ProgressView(value: fetcher.downloadingProgress)
                            .frame(width: 60)
                    }

                    downloadButton
                        .disabled(fetcher.isLoading)
                }
                .padding(imageButtonPadding)
                .font(Font.system(size: imageButtonSize, weight: .bold))
                .buttonStyle(PlainButtonStyle())
            }

            ImageView()
                .environmentObject(fetcher)
                .aspectRatio(previewImageAspectRatio, contentMode: .fill)

            setWallpaperButon
                .frame(width: 240, height: 40)
                .padding(imageButtonPadding)
                .buttonStyle(PlainButtonStyle())
                .disabled(fetcher.isLoading)
        }
    }

    private var preferencesButton: some View {
        Button(action: {
            withAnimation(.easeInOut) {
                currentView = .preference
            }
        }) {
            Image(systemName: "gearshape")
        }
    }

    private var historyButton: some View {
        Button(action: {
            withAnimation(.easeInOut) {
                currentView = .history
            }
        }) {
            Image(systemName: "clock")
        }
    }

    private var downloadButton: some View {
        Group {
            if fetcher.isDownloading {
                Button(action: {
                    fetcher.cancelDownload()
                }) {
                    Image(systemName: "xmark")
                }
            } else {
                Button(action: {
                    fetcher.download()
                }) {
                    Image(systemName: "square.and.arrow.down")
                }
            }
        }
    }

    private var setWallpaperButon: some View {
        Button(action: {
            // TODO: set as wallpaper
        }) {
            ZStack {
                // TODO: Button color
                Capsule()
                    .stroke(lineWidth: 2.0)

                Capsule()
                    .foregroundColor(.clear)

                Text("Set as Wallpaper")
            }
        }
    }

    // MARK: - Draw Constants

    private let previewImageAspectRatio: CGFloat = 1.6
    private let imageButtonSize: CGFloat = 16
    private let imageButtonPadding: CGFloat = 12
}

struct PreviewView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PersistenceController().container.viewContext
        let fetcher = WallpaperFetcher(in: viewContext)

        PreviewView(currentView: .constant(.preview))
            .environment(\.managedObjectContext, viewContext)
            .environmentObject(fetcher)
            .previewLayout(.sizeThatFits)
    }
}
