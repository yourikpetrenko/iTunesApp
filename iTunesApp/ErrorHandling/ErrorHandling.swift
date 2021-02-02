//
//  ErrorHandling.swift
//  iTunesApp
//
//  Created by Jura on 2/1/21.
//

import Foundation
import UIKit

// MARK: - Error handler in which methods are used to check for errors
final class ErrorHandler {
    static func checkoutForText(searchText: String) throws {
        guard searchText != "" else {
            throw ErrorList.noTextForSearchQuery
        }
    }
    
    static func checkoutForData(data: AlbumsListModel) throws {
        guard let data = data.results else { return }
        guard data.count != 0 else {
            throw ErrorList.nothingFound
        }
    }
}

//MARK: - Enum containing possible errors
enum ErrorList: Error {
    case noTextForSearchQuery
    case nothingFound
}

extension ErrorList: CustomStringConvertible {
    var description: String {
        switch self {
        case .noTextForSearchQuery: return "Invalid search data"
        case .nothingFound: return "Not found"
        }
    }
}
