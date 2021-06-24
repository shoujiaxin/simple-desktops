//
//  MockURLProtocol.swift
//  SimpleDesktopsTests
//
//  Created by Jiaxin Shou on 2021/6/26.
//

import Foundation

class MockURLProtocol: URLProtocol {
    typealias RequestHandler = (URLRequest) -> (Data?, HTTPURLResponse?, Error?)

    static var requestHandler: RequestHandler = { _ in
        (nil, nil, nil)
    }

    override class func canInit(with _: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        let (data, response, error) = Self.requestHandler(request)

        if let error = error {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }

        if let data = data, let response = response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
        }

        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
