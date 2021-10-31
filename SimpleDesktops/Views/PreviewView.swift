//
//  PreviewView.swift
//  SimpleDesktops
//
//  Created by Jiaxin Shou on 2021/1/15.
//

import Kingfisher
import SwiftUI

struct PreviewView: View {
    @Environment(\.colorScheme) private var colorScheme: ColorScheme

    @EnvironmentObject private var service: PictureService

    @State private var buttonHovering: Bool = false

    let picture: Picture?

    // MARK: - Views

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                KFImage(picture?.previewURL)
                    .resizable()
                    .aspectRatio(pictureAspectRatio, contentMode: .fit)
                    .transition(.opacity)

                if service.isFetching {
                    ProgressView(value: service.fetchingProgress)
                        .progressViewStyle(CircularProgressViewStyle())
                } else {
                    fetchButton
                }
            }

            Button {
                if let picture = picture {
                    service.setWallpaper(picture)
                }
            } label: {
                Text("Set as Wallpaper")
            }
            .buttonStyle(CapsuledButtonStyle())
            .padding(setWallpaperButtonPadding)
            .disabled(service.isFetching || service.isDownloading)
        }
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

    // MARK: - Constants

    private let setWallpaperButtonPadding: CGFloat = 12
    private let pictureAspectRatio: CGFloat = 1.6
    private let fetchButtonIconSize: CGFloat = 32
    private let fetchButtonFrameSize: CGFloat = 48
    private let fetchButtonCornerRadius: CGFloat = 8
    private let fetchButtonHoveringOpacity: Double = 0.8
    private let fetchButtonNormalOpacity: Double = 0.2
}

struct PreviewView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PersistenceController.preview.container.viewContext
        let picture = try? viewContext.fetch(Picture.fetchRequest(nil, fetchLimit: 1)).first
        PreviewView(picture: picture)
            .environmentObject(PictureService(context: viewContext))
            .frame(width: 400)
    }
}
