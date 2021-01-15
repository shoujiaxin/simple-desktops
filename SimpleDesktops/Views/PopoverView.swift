//
//  PopoverView.swift
//  SimpleDesktops
//
//  Created by Jiaxin Shou on 2021/1/14.
//

import CoreData
import SwiftUI

struct PopoverView: View {
//    @FetchRequest(fetchRequest: Wallpaper.fetchRequest(.all)) var wallpapers: FetchedResults<Wallpaper>

    enum ViewState {
        case preview
        case preference
        case history
    }

    @State private var currentView: ViewState = .preview

    var body: some View {
        let viewContext = PersistenceController().container.viewContext
        let fetcher = WallpaperFetcher(in: viewContext)

        Group {
            switch currentView {
            case .preview:
                PreviewView(currentView: $currentView)
                    .environment(\.managedObjectContext, viewContext)
                    .environmentObject(fetcher)

            case .preference: Text("Pre") // TODO: preference view

            case .history: Text("his") // TODO: history view
            }
        }
        .frame(width: 400)
    }
}

struct PopoverView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PersistenceController().container.viewContext
        let fetcher = WallpaperFetcher(in: viewContext)

        PopoverView()
            .environment(\.managedObjectContext, viewContext)
            .environmentObject(fetcher)
    }
}
