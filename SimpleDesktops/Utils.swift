//
//  Utils.swift
//  SimpleDesktops
//
//  Created by Jiaxin Shou on 2020/1/27.
//  Copyright © 2020 Jiaxin Shou. All rights reserved.
//

import Foundation
import SwiftSoup

class Utils {
    static func updateSimpleDesktopsMaxPage() {
        let queue = DispatchQueue(label: "Utils.updateSimpleDesktopsMaxPage")
        queue.async {
            while isSimpleDesktopsPageAvailable(page: Options.shared.simpleDesktopsMaxPage + 1) {
                Options.shared.simpleDesktopsMaxPage += 1
            }

            Options.shared.saveOptions()
        }
    }

    private static func isSimpleDesktopsPageAvailable(page: Int) -> Bool {
        let semaphore = DispatchSemaphore(value: 0)

        var isAvailable = false

        let url = URL(string: "http://simpledesktops.com/browse/\(page)/")!
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) { data, _, error in
            if error != nil {
                semaphore.signal()
                return
            }

            do {
                let doc: Document = try SwiftSoup.parse(String(data: data!, encoding: .utf8)!)
                let imgTags: Elements = try doc.select("img")

                if imgTags.count > 0 {
                    isAvailable = true
                }
                semaphore.signal()
            } catch {
                semaphore.signal()
                return
            }
        }
        task.resume()
        _ = semaphore.wait(timeout: .distantFuture)

        return isAvailable
    }
}
