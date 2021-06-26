//
//  SimpleDesktopsRequestTest.swift
//  SimpleDesktopsTests
//
//  Created by Jiaxin Shou on 2021/6/24.
//

@testable import Simple_Desktops

import Combine
import XCTest

class SimpleDesktopsRequestTest: XCTestCase {
    private var request: SimpleDesktopsRequest!

    private var cancellable: AnyCancellable?

    override func setUp() {
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
}
