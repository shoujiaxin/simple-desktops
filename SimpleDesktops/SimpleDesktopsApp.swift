//
//  SimpleDesktopsApp.swift
//  SimpleDesktops
//
//  Created by Jiaxin Shou on 2021/1/14.
//

import SwiftUI

@main
struct SimpleDesktopsApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
