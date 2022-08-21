//
//  ImageItem.swift
//  iOS-flickr-search
//
//  Created by Johannes Bjurströmer on 2022-08-21.
//

import Foundation

struct ImageResponse: Decodable {
    let photos: Images
    let stat: String
}

struct Images: Decodable {
    let photo: [ImageItem]
}

struct ImageItem: Decodable {
    let id: String
    let title: String
    let url_sq: String?
}
