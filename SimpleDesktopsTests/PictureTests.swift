//
//  PictureTests.swift
//  SimpleDesktopsTests
//
//  Created by Jiaxin Shou on 2021/9/25.
//

@testable import Simple_Desktops

import XCTest

class PictureTests: XCTestCase {
    private let context = PersistenceController.preview.container.viewContext

    func testRetrieveExisting() throws {
        let url =
            URL(
                string: "http://static.simpledesktops.com/uploads/desktops/2020/06/28/Big_Sur_Simple.png"
            )!
        let picture = Picture.retrieveFirst(with: url.absoluteString, for: \.url_, in: context)

        XCTAssertNotNil(picture?.id_)
        XCTAssertNotNil(picture?.lastFetchedTime_)
        XCTAssertEqual(picture?.name, "2020-06-28-Big_Sur_Simple.png")
        XCTAssertEqual(
            picture?.previewURL,
            URL(
                string: "http://static.simpledesktops.com/uploads/desktops/2020/06/28/Big_Sur_Simple.png.625x385_q100.png"
            )
        )
        XCTAssertEqual(picture?.url, url)
    }

    func testRetrieveNonExistent() throws {
        let url =
            URL(
                string: "http://static.simpledesktops.com/uploads/desktops/2021/02/04/mirage.png.295x184_q100.png"
            )!
        let picture = Picture.retrieveFirst(with: url.absoluteString, for: \.url_, in: context)

        XCTAssertNil(picture)
    }

    func testUpdate() throws {
        let link =
            "http://static.simpledesktops.com/uploads/desktops/2020/06/28/Big_Sur_Simple.png.625x385_q100.png"
        let info = SDPictureInfo(from: link)!
        let picture = Picture.retrieveFirst(
            with: info.url.absoluteString,
            for: \.url_,
            in: context
        )

        XCTAssertNotNil(picture?.id_)
        XCTAssertNotNil(picture?.lastFetchedTime_)
        XCTAssertEqual(picture?.name, info.name)
        XCTAssertEqual(picture?.previewURL, info.previewURL)
        XCTAssertEqual(picture?.url, info.url)

        let id = picture?.id
        let lastFetchedTime = picture?.lastFetchedTime

        picture?
            .update(with: SDPictureInfo(name: UUID().uuidString, previewURL: info.url,
                                        url: info.url))

        XCTAssertEqual(picture?.id, id)
        XCTAssertNotEqual(picture?.lastFetchedTime, lastFetchedTime)
        XCTAssertNotEqual(picture?.name, info.name)
        XCTAssertEqual(picture?.previewURL, info.url)
        XCTAssertEqual(picture?.url, info.url)
    }
}
