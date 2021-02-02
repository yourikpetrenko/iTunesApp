//
//  searchCell.swift
//  iTunesApp
//
//  Created by Jura on 1/29/21.
//

import UIKit

class SearchCell: UICollectionViewCell {
    
    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var albumNameLabel: UILabel!
    // MARK: - Configurate cell for collectionView
    func configurateCell(collectionView: UICollectionView, cell: SearchCell, dataForCell: AlbumsListModel, indexPath: IndexPath) -> UICollectionViewCell {
        if let indexPatnh = dataForCell.results?[indexPath.row] {
            guard let imageURL = URL(string: indexPatnh.artworkUrl100) else { return UICollectionViewCell() }
            guard let imageData = try? Data(contentsOf: imageURL) else { return UICollectionViewCell() }
            cell.albumImageView.image = UIImage(data: imageData)
            albumNameLabel.text = indexPatnh.collectionName
            artistName.text = indexPatnh.artistName
        }
        return cell
    }
}
