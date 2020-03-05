//
//  Copyright © 2020 Schnaub. All rights reserved.
//

@testable import MapleBacon
import XCTest

final class DownloaderTests: XCTestCase {

  private static let url = URL(string: "https://example.com/mapleBacon.png")!
  private static let cancelToken = 1

  func testDownload() {
    let expectation = self.expectation(description: #function)
    let configuration = MockURLProtocol.mockedURLSessionConfiguration()
    let downloader = Downloader<Data>(sessionConfiguration: configuration)

    setupMockResponse(.data(dummyData()))

    downloader.fetch(Self.url, token: Self.cancelToken) { response in
      switch response {
      case .success(let data):
        XCTAssertNotNil(data)
      case .failure:
        XCTFail()
      }
      expectation.fulfill()
    }

    waitForExpectations(timeout: 5, handler: nil)
  }

  func testInvalidData() {
    let expectation = self.expectation(description: #function)
    let configuration = MockURLProtocol.mockedURLSessionConfiguration()
    // The default mock response returns Data that cannot be deserialised into a UIImage
    let downloader = Downloader<UIImage>(sessionConfiguration: configuration)

    setupMockResponse(.data(dummyData()))

    downloader.fetch(Self.url, token: Self.cancelToken) { response in
      switch response {
      case .success:
        XCTFail()
      case .failure(let error):
        XCTAssertNotNil(error)

      }
      expectation.fulfill()
    }

    waitForExpectations(timeout: 5, handler: nil)
  }

  func testFailure() {
    let expectation = self.expectation(description: #function)
    let configuration = MockURLProtocol.mockedURLSessionConfiguration()
    let downloader = Downloader<Data>(sessionConfiguration: configuration)

    setupMockResponse(.error)

    downloader.fetch(Self.url, token: Self.cancelToken) { response in
      switch response {
      case .success:
        XCTFail()
      case .failure(let error):
        XCTAssertNotNil(error)
      }
      expectation.fulfill()
    }

    waitForExpectations(timeout: 5, handler: nil)
  }

  func testConcurrentDownloads() {
    let configuration = MockURLProtocol.mockedURLSessionConfiguration()
    let downloader = Downloader<Data>(sessionConfiguration: configuration)

    setupMockResponse(.data(dummyData()))

    let firstExpectation = expectation(description: "first")
    downloader.fetch(Self.url, token: Self.cancelToken) { response in
      switch response {
      case .success(let data):
        XCTAssertNotNil(data)
      case .failure:
        XCTFail()
      }
      firstExpectation.fulfill()
    }

    let secondExpectation = expectation(description: "second")
    downloader.fetch(Self.url, token: Self.cancelToken) { response in
      switch response {
      case .success(let data):
        XCTAssertNotNil(data)
      case .failure:
        XCTFail()
      }
      secondExpectation.fulfill()
    }

    waitForExpectations(timeout: 5, handler: nil)
  }

  func testCancel() {
    let expectation = self.expectation(description: #function)
    let configuration = MockURLProtocol.mockedURLSessionConfiguration()
    let downloader = Downloader<Data>(sessionConfiguration: configuration)

    setupMockResponse(.error)

    downloader.fetch(Self.url, token: Self.cancelToken) { response in
      switch response {
      case .success:
        XCTFail()
      case .failure(let error as NSError):
        XCTAssertEqual(error.code, -1)
      }
      expectation.fulfill()
    }
    downloader.cancel(token: Self.cancelToken)

    waitForExpectations(timeout: 5, handler: nil)
  }

}
