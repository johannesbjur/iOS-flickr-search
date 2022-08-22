//
//  ImageInfoPresenter.swift
//  iOS-flickr-search
//
//  Created by Johannes Bjurströmer on 2022-08-22.
//

import Foundation

protocol ImageInfoPresenterProtocol {
    func viewDidLoad() async
}

final class ImageInfoPresenter: ImageInfoPresenterProtocol {
    private let imageId: String
    private let imageDownloadService: ImageDownloadServiceProtocol
    private weak var viewDelegate: ImageInfoViewControllerProtocol?
    
    init(imageDownloadService: ImageDownloadServiceProtocol, viewDelegate: ImageInfoViewControllerProtocol, imageId: String) {
        self.imageDownloadService = imageDownloadService
        self.viewDelegate = viewDelegate
        self.imageId = imageId
    }
    
    func viewDidLoad() async {
        do {
            let imageInfo = try await imageDownloadService.fetchImageInfo(with: imageId)
            viewDelegate?.setTitleLabel(text: imageInfo.title._content)
            viewDelegate?.setDescriptionLabel(text: imageInfo.description._content)
        } catch {
            
        }
        
    }
}
