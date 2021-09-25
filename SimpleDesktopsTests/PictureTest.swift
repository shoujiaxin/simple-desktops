//
//  PictureTest.swift
//  SimpleDesktopsTests
//
//  Created by Jiaxin Shou on 2021/9/25.
//

@testable import Simple_Desktops

import XCTest

class PictureTest: XCTestCase {
    let context = PersistenceController.preview.container.viewContext

    func testFetchPictureWithURL() throws {
        let url = URL(string: "http://static.simpledesktops.com/uploads/desktops/2020/06/28/Big_Sur_Simple.png")!
        let picture = Picture.withURL(url, in: context)
        XCTAssertNotNil(picture.id_)
        XCTAssertNotNil(picture.lastFetchedTime_)
        XCTAssertEqual(picture.name, "2020-06-28-Big_Sur_Simple")
        XCTAssertEqual(picture.previewURL, URL(string: "http://static.simpledesktops.com/uploads/desktops/2020/06/28/Big_Sur_Simple.png.625x385_q100.png"))
        XCTAssertEqual(picture.url, url)
    }

    func testCreatePictureWithURL() throws {
        let url = URL(string: "http://static.simpledesktops.com/uploads/desktops/2021/02/04/mirage.png.295x184_q100.png")!
        let picture = Picture.withURL(url, in: context)
        XCTAssertNil(picture.id_)
        XCTAssertNil(picture.lastFetchedTime_)
        XCTAssertNil(picture.name)
        XCTAssertNil(picture.previewURL)
        XCTAssertEqual(picture.url, url)
    }
}
