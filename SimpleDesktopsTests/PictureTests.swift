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
        let pictureBefore = Picture.retrieveFirst(
            with: info.url.absoluteString,
            for: \.url_,
            in: context
        )

        XCTAssertNotNil(pictureBefore?.id_)
        XCTAssertNotNil(pictureBefore?.lastFetchedTime_)
        XCTAssertEqual(pictureBefore?.name, info.name)
        XCTAssertEqual(pictureBefore?.previewURL, info.previewURL)
        XCTAssertEqual(pictureBefore?.url, info.url)

        let lastFetchedTime = pictureBefore?.lastFetchedTime
        let name = pictureBefore?.name

        let newInfo = SDPictureInfo(name: UUID().uuidString, previewURL: info.url, url: info.url)
        let pictureAfter = Picture.update(with: newInfo, in: context)

        XCTAssertEqual(pictureAfter, pictureBefore)
        XCTAssertNotNil(pictureAfter.id_)
        XCTAssertNotEqual(pictureAfter.lastFetchedTime, lastFetchedTime)
        XCTAssertEqual(pictureAfter.name, newInfo.name)
        XCTAssertNotEqual(pictureAfter.name, name)
        XCTAssertEqual(pictureAfter.previewURL, newInfo.previewURL)
        XCTAssertEqual(pictureAfter.previewURL, info.url)
        XCTAssertEqual(pictureAfter.url, newInfo.url)
    }

    func testAdd() throws {
        let link =
            "http://static.simpledesktops.com/uploads/desktops/2021/02/04/mirage.png.295x184_q100.png"
        let info = SDPictureInfo(from: link)!
        let picture = Picture.update(with: info, in: context)

        XCTAssertNotNil(picture.id_)
        XCTAssertNotNil(picture.lastFetchedTime_)
        XCTAssertEqual(picture.name, info.name)
        XCTAssertEqual(picture.previewURL, info.previewURL)
        XCTAssertEqual(picture.url, info.url)
    }
}
