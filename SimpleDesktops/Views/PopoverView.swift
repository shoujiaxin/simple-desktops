//
//  PopoverView.swift
//  SimpleDesktops
//
//  Created by Jiaxin Shou on 2021/1/14.
//

import CoreData
import SwiftUI

struct PopoverView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(fetchRequest: Wallpaper.fetchRequest(.all)) var wallpapers: FetchedResults<Wallpaper>

    // MARK: - Views

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Group {
                    preferencesButton

                    historyButton

                    Spacer()

                    downloadButton
                }
                .padding(imageButtonPadding)
                .font(Font.system(size: imageButtonSize, weight: .bold))
                .buttonStyle(PlainButtonStyle())
            }

            PreviewView(of: wallpapers.first)
                .aspectRatio(previewImageAspectRatio, contentMode: .fill)

            setWallpaperButon
                .frame(width: 240, height: 40)
                .padding(imageButtonPadding)
                .buttonStyle(PlainButtonStyle())
        }
        .frame(width: 400)
    }

    private var preferencesButton: some View {
        Button(action: {
            // TODO: to preferences
        }) {
            Image(systemName: "gearshape")
        }
    }

    private var historyButton: some View {
        Button(action: {
            // TODO: to histories
        }) {
            Image(systemName: "clock")
        }
    }

    private var downloadButton: some View {
        Button(action: {
            // TODO: download
        }) {
            Image(systemName: "square.and.arrow.down")
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        PopoverView()
//            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
