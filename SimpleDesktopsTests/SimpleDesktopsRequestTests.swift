//
//  SimpleDesktopsRequestTests.swift
//  SimpleDesktopsTests
//
//  Created by Jiaxin Shou on 2021/6/24.
//

@testable import Simple_Desktops

import Combine
import XCTest

class SimpleDesktopsRequestTests: XCTestCase {
    private var request: SimpleDesktopsRequest!

    private var cancellable: AnyCancellable?

    override func setUp() {
        super.setUp()
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockURLProtocol.self]
        request = SimpleDesktopsRequest(session: URLSession(configuration: configuration))

        cancellable?.cancel()
    }

    func testRandomPictureSuccess() throws {
        MockURLProtocol.requestHandler = { _ in
            let html = """
            <!DOCTYPE html>
            <html lang="en">
              <head>
                <meta charset="UTF-8" />
                <meta http-equiv="X-UA-Compatible" content="IE=edge" />
                <meta name="viewport" content="width=device-width, initial-scale=1.0" />
                <title>Document</title>
              </head>
              <body>
                <div class="edge">
                  <div class="desktop" height="184px">
                    <a href="/browse/desktops/2021/feb/04/mirage/">
                      <img
                        src="http://static.simpledesktops.com/uploads/desktops/2021/02/04/mirage.png.295x184_q100.png"
                        title="mirage"
                        alt="mirage"
                        width="295px"
                        height="184px"
                      />
                    </a>
                    <h2><a href="/browse/desktops/2021/feb/04/mirage/">mirage</a></h2>
                    <span class="creator">By: <a href="">lucy</a></span>
                  </div>
                </div>
              </body>
            </html>
            """
            let data = html.data(using: .utf8)
            let response = HTTPURLResponse(url: URL(string: "http://simpledesktops.com/browse/")!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: nil)
            return (data, response, nil)
        }

        let expectation = expectation(description: "testRandomPictureSuccess")
        cancellable = request.randomPicture
            .sink(receiveCompletion: { completion in
                switch completion {
                case let .failure(error):
                    XCTFail(error.localizedDescription)
                case .finished:
                    break
                }
                expectation.fulfill()
            }) { info in
                XCTAssertEqual(info.name, "2021-02-04-mirage.png")
                XCTAssertEqual(info.previewURL, URL(string: "http://static.simpledesktops.com/uploads/desktops/2021/02/04/mirage.png.295x184_q100.png")!)
                XCTAssertEqual(info.url, URL(string: "http://static.simpledesktops.com/uploads/desktops/2021/02/04/mirage.png")!)
            }

        waitForExpectations(timeout: 5)
    }

    func testRandomPictureError() throws {
        MockURLProtocol.requestHandler = { _ in
            (nil, nil, SimpleDesktopsError.soupFailed)
        }

        let expectation = expectation(description: "testRandomPictureError")
        cancellable = request.randomPicture
            .sink(receiveCompletion: { completion in
                switch completion {
                case let .failure(error):
                    XCTAssertNotNil(error)
                case .finished:
                    break
                }
                expectation.fulfill()
            }) { _ in
                XCTFail()
            }

        waitForExpectations(timeout: 5)
    }

    func testSDPictureInfo() throws {
        let name = "2020-06-28-Big_Sur_Simple"
        let previewURL = URL(string: "http://static.simpledesktops.com/uploads/desktops/2020/06/28/Big_Sur_Simple.png.625x385_q100.png")!
        let url = URL(string: "http://static.simpledesktops.com/uploads/desktops/2020/06/28/Big_Sur_Simple.png")!

        XCTAssertNil(SDPictureInfo(name: nil, previewURL: previewURL, url: url))
        XCTAssertNil(SDPictureInfo(name: name, previewURL: nil, url: url))
        XCTAssertNil(SDPictureInfo(name: name, previewURL: previewURL, url: nil))

        let info = SDPictureInfo(name: name, previewURL: previewURL, url: url)
        XCTAssertNotNil(info)
        XCTAssertEqual(info?.name, name)
        XCTAssertEqual(info?.previewURL, previewURL)
        XCTAssertEqual(info?.url, url)
    }

    func testUpdatePictureWithSDPictureInfo() throws {
        let name = "2020-06-28-Big_Sur_Simple"
        let previewURL = URL(string: "http://static.simpledesktops.com/uploads/desktops/2020/06/28/Big_Sur_Simple.png.625x385_q100.png")!
        let url = URL(string: "http://static.simpledesktops.com/uploads/desktops/2020/06/28/Big_Sur_Simple.png")!
        let info = SDPictureInfo(name: name, previewURL: previewURL, url: url)!
        let context = PersistenceController.preview.container.viewContext

        let picture = Picture.update(from: info, in: context)
        XCTAssertNotNil(picture.id_)
        XCTAssertNotNil(picture.lastFetchedTime_)
        XCTAssertEqual(picture.name, name)
        XCTAssertEqual(picture.previewURL, previewURL)
        XCTAssertEqual(picture.url, url)
    }
}
