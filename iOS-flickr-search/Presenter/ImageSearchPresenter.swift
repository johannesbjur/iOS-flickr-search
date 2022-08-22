//
//  ImageSearchPresenter.swift
//  iOS-flickr-search
//
//  Created by Johannes Bjurströmer on 2022-08-21.
//

import Foundation

protocol ImageSearchPresenterProtocol {
    func fetchImages(with string: String) async
}

final class ImageSearchPresenter: ImageSearchPresenterProtocol {
    private let imageDownloadService: ImageDownloadServiceProtocol
    private weak var viewDelegate: ImageSearchViewControllerProtocol?
    
    init(imageDownloadService: ImageDownloadServiceProtocol, viewDelegate: ImageSearchViewControllerProtocol) {
        self.imageDownloadService = imageDownloadService
        self.viewDelegate = viewDelegate
    }
    
    func fetchImages(with string: String) async {
        do {
            for imageItem in try await imageDownloadService.fetchImageItems(with: string) {
                guard let urlString = imageItem.url_sq,
                      let url = URL(string: urlString) else { continue }
                let imageData = try await imageDownloadService.fetchImageData(from: url)
                viewDelegate?.addImageDataToCollectionView(imageData: imageData, imageId: imageItem.id)
            }
        } catch let error as ImageDownloadError {
            let message: String
            switch error {
            case .urlParsingError:
                message = "Url parsing error"
            case .apiResponseError:
                message = "Api response error"
            case .imageParsingError:
                message = "Image Parsing error"
            }
            viewDelegate?.showError(with: message)
        } catch {
            viewDelegate?.showError(with: "Generic error")
        }
    }
}
