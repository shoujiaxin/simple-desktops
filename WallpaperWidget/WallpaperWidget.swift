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
        let entry = SimpleEntry(date: Date(), url: nil)
        completion(entry)
    }

    func getTimeline(in _: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        var entries: [SimpleEntry] = []

        let fileURLs = try! FileManager.default.contentsOfDirectory(at: WallpaperManager.shared.directory,
                                                                    includingPropertiesForKeys: nil,
                                                                    options: .skipsHiddenFiles)

        let currentDate = Date()
        for i in 0 ..< fileURLs.count {
            let entryDate = Calendar.current.date(byAdding: .minute, value: 10 * i, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, url: fileURLs[i])
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
           let image = NSImage(contentsOf: url)
        {
            Image(nsImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .widgetURL(URL(string: "widget-deeplink://\(url.lastPathComponent)")!)
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
        WallpaperWidgetEntryView(entry: SimpleEntry(date: Date(), url: nil))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
