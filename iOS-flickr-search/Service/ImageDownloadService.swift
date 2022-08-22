//
//  ImageDownloadService.swift
//  iOS-flickr-search
//
//  Created by Johannes Bjurströmer on 2022-08-21.
//

import Foundation

private enum Constants {
    static let domain = "https://flickr.com"
    static let path = "/services/rest"
    static let apiKey = "&api_key=8fc9186e406bb7d0a9ddb9c9bbd0db2f"
    static let searchMethod = "?method=flickr.photos.search"
    static let infoMethod = "?method=flickr.photos.getInfo"
    static let parameters = "&per_page=20&page=1&format=json&extras=url_sq&nojsoncallback=true"
    static let tags = "&tags="
    static let imageId = "&photo_id="
}

enum ImageDownloadError: Error {
    case urlParsingError
    case apiResponseError
    case imageParsingError
}

protocol ImageDownloadServiceProtocol {
    func fetchImageItems(with string: String) async throws -> [ImageItem]
    func fetchImageData(from url: URL) async throws -> Data
    func fetchImageInfo(with id: String) async throws -> ImageInfo
}

final class ImageDownloadService: ImageDownloadServiceProtocol {
    func fetchImageItems(with string: String) async throws -> [ImageItem] {
        let urlString = Constants.domain + Constants.path + Constants.searchMethod + Constants.parameters + Constants.tags + string + Constants.apiKey
        guard let url = URL(string: urlString) else { throw ImageDownloadError.urlParsingError }

        let (data, response) = try await URLSession.shared.data(from: url, delegate: nil)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw ImageDownloadError.apiResponseError
        }

        do {
            let imageItem = try JSONDecoder().decode(ImageResponse.self, from: data)
            return imageItem.photos.photo
        } catch {
            throw ImageDownloadError.imageParsingError
        }
    }

    func fetchImageData(from url: URL) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(from: url, delegate: nil)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw ImageDownloadError.apiResponseError
        }
        return data
    }

    func fetchImageInfo(with id: String) async throws -> ImageInfo {
        let urlString = Constants.domain + Constants.path + Constants.infoMethod + Constants.parameters + Constants.imageId + id + Constants.apiKey
        guard let url = URL(string: urlString) else { throw ImageDownloadError.urlParsingError }
        
        let (data, response) = try await URLSession.shared.data(from: url, delegate: nil)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw ImageDownloadError.apiResponseError
        }
        
        do {
            let imageInfo = try JSONDecoder().decode(ImageInfoResponse.self, from: data)
            print(imageInfo)
            return imageInfo.photo
        } catch {
            throw ImageDownloadError.imageParsingError
        }
    }
}
