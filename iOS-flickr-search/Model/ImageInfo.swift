//
//  ImageInfo.swift
//  iOS-flickr-search
//
//  Created by Johannes Bjurströmer on 2022-08-22.
//

import Foundation

struct ImageInfoResponse: Decodable {
    let photo: ImageInfo
    let stat: String
}

struct ImageInfo: Decodable {
    let id: String
    let title, description: ContentInfo
}

struct ContentInfo: Decodable {
    let _content: String
}
