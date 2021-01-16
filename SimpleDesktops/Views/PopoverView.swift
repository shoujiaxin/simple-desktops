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

        var height: CGFloat {
            self == .preference ? 163 : 358
        }
    }

    @State private var currentView: ViewState = .preview

    private var viewContext: NSManagedObjectContext!
    private var fetcher: WallpaperFetcher!
    private var preferences: Preferences!

    init() {
        viewContext = PersistenceController().container.viewContext
        fetcher = WallpaperFetcher(in: viewContext)
        preferences = Preferences()
    }

    var body: some View {
        Group {
            switch currentView {
            case .preview:
                PreviewView(currentView: $currentView)
                    .environment(\.managedObjectContext, viewContext)
                    .environmentObject(fetcher)

            case .preference:
                PreferenceView(preferences: Preferences(), currentView: $currentView)
                    .transition(.move(edge: .bottom))

            case .history:
                HistoryView(currentView: $currentView)
                    .environment(\.managedObjectContext, viewContext)
                    .environmentObject(fetcher)
                    .transition(.move(edge: .trailing))
            }
        }
        .frame(width: 400, height: currentView.height)
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
