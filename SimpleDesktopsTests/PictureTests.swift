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

    func testFetchPictureWithURL() throws {
        let url =
            URL(
                string: "http://static.simpledesktops.com/uploads/desktops/2020/06/28/Big_Sur_Simple.png"
            )!
        let picture = Picture.withURL(url, in: context)

        XCTAssertNotNil(picture.id_)
        XCTAssertNotNil(picture.lastFetchedTime_)
        XCTAssertEqual(picture.name, "2020-06-28-Big_Sur_Simple.png")
        XCTAssertEqual(
            picture.previewURL,
            URL(
                string: "http://static.simpledesktops.com/uploads/desktops/2020/06/28/Big_Sur_Simple.png.625x385_q100.png"
            )
        )
        XCTAssertEqual(picture.url, url)
    }

    func testCreatePictureWithURL() throws {
        let url =
            URL(
                string: "http://static.simpledesktops.com/uploads/desktops/2021/02/04/mirage.png.295x184_q100.png"
            )!
        let picture = Picture.withURL(url, in: context)

        XCTAssertNil(picture.id_)
        XCTAssertNil(picture.lastFetchedTime_)
        XCTAssertNil(picture.name)
        XCTAssertNil(picture.previewURL)
        XCTAssertEqual(picture.url, url)
    }

    func testUpdate() throws {
        let link =
            "http://static.simpledesktops.com/uploads/desktops/2020/06/28/Big_Sur_Simple.png.625x385_q100.png"
        let info = SDPictureInfo(from: link)!
        let pictureBefore = Picture.withURL(info.url, in: context)
        let date = pictureBefore.lastFetchedTime

        XCTAssertNotNil(pictureBefore.id_)
        XCTAssertNotNil(pictureBefore.lastFetchedTime_)
        XCTAssertEqual(pictureBefore.name, info.name)
        XCTAssertEqual(pictureBefore.previewURL, info.previewURL)
        XCTAssertEqual(pictureBefore.url, info.url)

        let pictureAfter = Picture.update(with: info, in: context)

        XCTAssertNotNil(pictureAfter.id_)
        XCTAssertNotEqual(date, pictureAfter.lastFetchedTime)
        XCTAssertEqual(pictureAfter.name, info.name)
        XCTAssertEqual(pictureAfter.previewURL, info.previewURL)
        XCTAssertEqual(pictureAfter.url, info.url)
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
