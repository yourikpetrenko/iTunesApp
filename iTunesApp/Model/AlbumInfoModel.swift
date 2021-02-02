//
//  AlbumModel.swift
//  iTunesApp
//
//  Created by Jura on 1/29/21.
//

import Foundation

struct AlbumsListModel: Decodable {
    var results: [AlbumInfoModel]?
}

struct AlbumInfoModel: Decodable {
    var artworkUrl100: String
    var artistName: String
    var collectionName: String
    var collectionId: Int
}

