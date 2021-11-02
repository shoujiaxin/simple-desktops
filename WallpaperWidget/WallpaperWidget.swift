//
//  WallpaperWidget.swift
//  WallpaperWidget
//
//  Created by Jiaxin Shou on 2021/2/9.
//

import SwiftUI
import WidgetKit

struct Provider: TimelineProvider {
    func placeholder(in _: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), url: nil)
    }

    func getSnapshot(in _: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(date: Date(),
                                url: try? FileManager.default.contentsOfDirectory(
                                    at: WallpaperManager.directory,
                                    includingPropertiesForKeys: nil,
                                    options: .skipsHiddenFiles
                                ).randomElement())
        completion(entry)
    }

    func getTimeline(in _: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        var entries: [SimpleEntry] = []

        let fileURLs = try! FileManager.default.contentsOfDirectory(
            at: WallpaperManager.directory,
            includingPropertiesForKeys: nil,
            options: .skipsHiddenFiles
        ).shuffled()

        let currentDate = Date()
        for (index, url) in fileURLs.enumerated() {
            let entryDate = Calendar.current.date(
                byAdding: .minute,
                value: 15 * index,
                to: currentDate
            )!
            let entry = SimpleEntry(date: entryDate, url: url)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date

    let url: URL?
}

struct WallpaperWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        if let url = entry.url,
           let image = NSImage(contentsOf: url) {
            Image(nsImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .widgetURL(URL(string: "widget-deeplink://\(url.lastPathComponent)")!)
        } else {
            Image(systemName: "photo.on.rectangle.angled")
                .font(Font.system(size: 64))
                .foregroundColor(.secondary)
        }
    }
}

@main
struct WallpaperWidget: Widget {
    let kind: String = "WallpaperWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WallpaperWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Wallpapers")
        .description("View all history wallpapers.")
    }
}

struct WallpaperWidget_Previews: PreviewProvider {
    static var previews: some View {
        let emptyEntry = SimpleEntry(date: Date(), url: nil)
        WallpaperWidgetEntryView(entry: emptyEntry)
            .previewContext(WidgetPreviewContext(family: .systemSmall))

        let demoEntry = SimpleEntry(date: Date(),
                                    url: try? FileManager.default.contentsOfDirectory(
                                        at: WallpaperManager.directory,
                                        includingPropertiesForKeys: nil,
                                        options: .skipsHiddenFiles
                                    ).randomElement())
        WallpaperWidgetEntryView(entry: demoEntry)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
