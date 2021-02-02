//
//  HistoryInfoVC.swift
//  iTunesApp
//
//  Created by Jura on 2/1/21.
//

import UIKit

final class HistoryInfoVC: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var albums = AlbumsListModel()
    private let networkService: NetworkServiceProtocol = NetworkService()
    var albumID = Int()
    var itemFromHistory = String() {
        didSet {
            gettingDataNetwork(searchText: itemFromHistory)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupDelegate()
        self.cellRegistration()
        self.activityIndicatorStopAnimating()
    }
    // MARK: - Setup Delegate, DataSource
    private func setupDelegate() {
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
    }
    // MARK: - Registration cell for collectionView
    private func cellRegistration() {
        self.collectionView.register(UINib(nibName: "SearchCell", bundle: nil),
                                forCellWithReuseIdentifier: "cellectionIDCell")
    }
    
    private func activityIndicatorStartAnimating() {
        DispatchQueue.main.async {
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
        }
    }
    
    private func activityIndicatorStopAnimating() {
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true
    }
    // MARK: - Getting albums from Network
    private func gettingDataNetwork(searchText: String) {
        networkService.getListAlbums(searchText: searchText) { result in
            switch result {
            case .success(let datailAlbums):
                do {
                    self.activityIndicatorStartAnimating()
                   try ErrorHandler.checkoutForData(data: datailAlbums)
                    self.albums = self.sortingAlbum(arrayAlbums: datailAlbums)
                    DispatchQueue.main.async {
                        self.activityIndicatorStopAnimating()
                        self.collectionView.reloadData()
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.createAlertForViewError(description: ErrorList.nothingFound.description)
                    }
                }
            case .failure(let error):
                self.createAlertForViewError(description: error.localizedDescription)
            }
        }
    }
    // MARK: - Extract the id to get information about the album
    private func extractCollectionID(indexPath: IndexPath) -> Int {
        var selectedAlbumID = Int()
        if let indexPatnh = albums.results?[indexPath.row] {
            selectedAlbumID = indexPatnh.collectionId
        }
        return selectedAlbumID
    }
    // MARK: - Sort albums alphabetically
    private func sortingAlbum(arrayAlbums: AlbumsListModel) -> AlbumsListModel {
        let sortedResult = arrayAlbums.results?.sorted{(oneElement, secondElement) -> Bool in
            return oneElement.collectionName < secondElement.collectionName
        }
        self.albums.results = sortedResult
        let sortedAlbums = albums
        return sortedAlbums
    }
    // MARK: - Preparing for the transition
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fromHistoryToDetail" {
            let detailVC = segue.destination as! DetailHistoryVC
            detailVC.albumID = albumID
        }
    }
}
// MARK: - UICollectionViewDataSource, UICollectionViewDelegate, action when selecting item
extension HistoryInfoVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albums.results?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellectionIDCell", for: indexPath) as! SearchCell
        return cell.configurateCell(collectionView: collectionView, cell: cell, dataForCell: albums, indexPath: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        albumID = self.extractCollectionID(indexPath: indexPath)
        performSegue(withIdentifier: "fromHistoryToDetail", sender: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 150)
    }
}
// MARK: - Create UIAlertController For View Error
extension HistoryInfoVC {
    private func createAlertForViewError(description: String) {
        let alert = UIAlertController(title: "Error", message: description, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okButton)
        self.present(alert, animated: true)
    }
}

