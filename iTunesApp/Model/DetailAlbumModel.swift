//
//  DetailAlbum.swift
//  iTunesApp
//
//  Created by Jura on 1/31/21.
//

import Foundation

struct DetailAlbumsListModel: Decodable {
    var results: [DetailAlbumModel]?
}

struct DetailAlbumModel: Codable {
    var wrapperType: String
    var artistName: String
    var collectionName: String
    var artworkUrl60: String
    var trackName: String?
}
