//
//  iOS_flickr_searchTests.swift
//  iOS-flickr-searchTests
//
//  Created by Johannes Bjurströmer on 2022-08-21.
//

import XCTest
@testable import iOS_flickr_search

final class PresenterTests: XCTestCase {
    var presenter: ImageSearchPresenterProtocol!
    private var mockService: MockService!
    private var mockViewController: MockViewController!
    
    override func setUp() {
        super.setUp()
        mockService = MockService()
        mockViewController = MockViewController()
        presenter = ImageSearchPresenter(imageDownloadService: mockService,
                                         viewDelegate: mockViewController)
    }
    
    override func tearDown() {
        super.tearDown()
        presenter = nil
        mockService = nil
        mockViewController = nil
    }

    func testPresenter_serviceReturnsImageData_shouldCallAddToCollectionView() async {
        await presenter.fetchImages(with: "testString")
        XCTAssertTrue(mockService.fetchImageItemsCalled)
        XCTAssertTrue(mockService.fetchImageDataCalled)
        XCTAssertEqual(mockService.fetchImageItemsSearchString, "testString")
        XCTAssertTrue(mockViewController.addImageDataToCollectionViewCalled)
    }

    func testPresenter_serviceReturnsImageDownloadError_shouldShowErrorMessage() async {
        mockService.fetchImageDataError = ImageDownloadError.urlParsingError
        await presenter.fetchImages(with: "testString")
        XCTAssertTrue(mockService.fetchImageItemsCalled)
        XCTAssertTrue(mockService.fetchImageDataCalled)
        XCTAssertEqual(mockViewController.errorMessage, "Url parsing error")
    }

    func testPresenter_serviceReturnsGenericError_shouldShowGenericError() async {
        mockService.fetchImageDataError = MockError.genericError
        await presenter.fetchImages(with: "testString")
        XCTAssertTrue(mockService.fetchImageItemsCalled)
        XCTAssertTrue(mockService.fetchImageDataCalled)
        XCTAssertEqual(mockViewController.errorMessage, "Generic error")
    }
}

private enum MockError: Error {
    case genericError
}

private final class MockService: ImageDownloadServiceProtocol {
    var fetchImageItemsCalled: Bool = false
    var fetchImageDataCalled: Bool = false
    var fetchImageDataError: Error?
    var fetchImageItemsSearchString: String = ""
    
    func fetchImageItems(with string: String) async throws -> [ImageItem] {
        fetchImageItemsCalled = true
        fetchImageItemsSearchString = string
        return [ImageItem(id: "1", title: "test", url_sq: "urlstring")]
    }

    func fetchImageData(from url: URL) async throws -> Data {
        fetchImageDataCalled = true
        if let fetchImageDataError = fetchImageDataError {
            throw fetchImageDataError
        }
        return Data()
    }

    func fetchImageInfo(with id: String) async throws -> ImageInfo {
        return ImageInfo(id: "123", title: ContentInfo(_content: "test"), description: ContentInfo(_content: "test"))
    }
}

private final class MockViewController: ImageSearchViewControllerProtocol {
    var errorMessage: String = ""
    var addImageDataToCollectionViewCalled: Bool = false

    func showError(with message: String) {
        errorMessage = message
    }

    func addImageDataToCollectionView(imageData: Data, imageId: String) {
        addImageDataToCollectionViewCalled = true
    }
}
