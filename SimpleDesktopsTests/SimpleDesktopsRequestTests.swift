//
//  SimpleDesktopsRequestTests.swift
//  SimpleDesktopsTests
//
//  Created by Jiaxin Shou on 2021/6/24.
//

@testable import Simple_Desktops

import XCTest

class SimpleDesktopsRequestTests: XCTestCase {
    private var request: SimpleDesktopsRequest!

    override func setUp() {
        super.setUp()

        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockURLProtocol.self]
        request = SimpleDesktopsRequest(session: URLSession(configuration: configuration))
    }

    func testRandom() async throws {
        MockURLProtocol.requestHandler = { _ in
            let data = try! Data(contentsOf: Bundle(for: type(of: self))
                .url(forResource: "SimpleDesktopsRequestTests", withExtension: "html")!)
            let response = HTTPURLResponse(
                url: URL(string: "http://simpledesktops.com/browse/")!,
                statusCode: 200,
                httpVersion: "HTTP/1.1",
                headerFields: nil
            )
            return (data, response, nil)
        }

        let info = try await request.random()
        XCTAssertEqual(info.name, "2021-02-04-mirage.png")
        XCTAssertEqual(
            info.previewURL,
            URL(
                string: "http://static.simpledesktops.com/uploads/desktops/2021/02/04/mirage.png.295x184_q100.png"
            )!
        )
        XCTAssertEqual(
            info.url,
            URL(string: "http://static.simpledesktops.com/uploads/desktops/2021/02/04/mirage.png")!
        )
    }
}
