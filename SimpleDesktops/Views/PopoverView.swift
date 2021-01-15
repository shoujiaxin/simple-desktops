//
//  PopoverView.swift
//  SimpleDesktops
//
//  Created by Jiaxin Shou on 2021/1/14.
//

import CoreData
import SwiftUI

struct PopoverView: View {
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

            case .history:
                HistoryView(currentView: $currentView)
                    .environment(\.managedObjectContext, viewContext)
                    .transition(.move(edge: .trailing))
            }
        }
        .frame(width: 400, height: 358) // TODO: reactive size
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
