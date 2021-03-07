//
//  PopoverView.swift
//  Simple Desktops
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
                return 163
            case .preview,
                 .history:
                return 358
            }
        }
    }

    @State private var currentView: ViewState = .preview

    private let preferences = Preferences()

    var body: some View {
        Group {
            switch currentView {
            case .preview:
                PreviewView(currentView: $currentView)

            case .preference:
                PreferenceView(currentView: $currentView, preferences: preferences)
                    .transition(.move(edge: .bottom))

            case .history:
                HistoryView(currentView: $currentView)
                    .transition(.move(edge: .trailing))
            }
        }
        .frame(width: 400, height: currentView.height)
    }
}

struct PopoverView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PersistenceController.preview.container.viewContext
        PopoverView()
            .environment(\.managedObjectContext, viewContext)
            .environmentObject(PictureFetcher(context: viewContext))
    }
}
