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

    private var cancellables: Set<AnyCancellable> = []

    override func setUp() {
        super.setUp()

        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockURLProtocol.self]
        request = SimpleDesktopsRequest(session: URLSession(configuration: configuration))
    }

    override func tearDown() {
        cancellables.forEach { $0.cancel() }
        cancellables = []
    }

    func testRandomPictureSuccess() throws {
        MockURLProtocol.requestHandler = { _ in
            let data = try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "SimpleDesktopsRequestTests", withExtension: "html")!)
            let response = HTTPURLResponse(url: URL(string: "http://simpledesktops.com/browse/")!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: nil)
            return (data, response, nil)
        }

        let expectation = expectation(description: "SimpleDesktopsRequestTests.testRandomPictureSuccess")
        request.randomPicture
            .sink { completion in
                switch completion {
                case let .failure(error):
                    XCTFail(error.localizedDescription)
                case .finished:
                    break
                }
                expectation.fulfill()
            } receiveValue: { info in
                XCTAssertEqual(info.name, "2021-02-04-mirage.png")
                XCTAssertEqual(info.previewURL, URL(string: "http://static.simpledesktops.com/uploads/desktops/2021/02/04/mirage.png.295x184_q100.png")!)
                XCTAssertEqual(info.url, URL(string: "http://static.simpledesktops.com/uploads/desktops/2021/02/04/mirage.png")!)
            }
            .store(in: &cancellables)

        waitForExpectations(timeout: 5)
    }

    func testRandomPictureError() throws {
        MockURLProtocol.requestHandler = { _ in
            (nil, nil, SimpleDesktopsError.soupFailed)
        }

        let expectation = expectation(description: "SimpleDesktopsRequestTests.testRandomPictureError")
        request.randomPicture
            .sink { completion in
                switch completion {
                case let .failure(error):
                    XCTAssertNotNil(error)
                case .finished:
                    break
                }
                expectation.fulfill()
            } receiveValue: { _ in
                XCTFail()
            }
            .store(in: &cancellables)

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
