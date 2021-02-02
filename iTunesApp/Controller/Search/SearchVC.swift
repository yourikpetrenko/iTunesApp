//
//  ViewController.swift
//  iTunesApp
//
//  Created by Jura on 1/28/21.
//

import UIKit

class SearchVC: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    private var albums = AlbumsListModel()
    private let networkService: NetworkServiceProtocol = NetworkService()
    var albumID = Int()
    private var arrayHistory: [String] {
        get {
            return UserDefaults.standard.stringArray(forKey: "savedArraySearch") ?? [String]()
        } set {
            UserDefaults.standard.set(newValue, forKey: "savedArraySearch")
            UserDefaults.standard.synchronize()
        }
    }
    // MARK: - After entering the text for the search query, the method for retrieving data from the network is started
    private var searchBarText = String() {
        didSet {
            self.searchBar.setShowsCancelButton(true, animated: true)
            self.gettingDataNetwork()
            arrayHistory.insert(searchBarText, at: 0)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDelegate()
        cellRegistration()
        activityIndicatorStopAnimating()
    }
    // MARK: - Setup Delegate, DataSource
    private  func setupDelegate() {
        collectionView.dataSource = self
        collectionView.delegate = self
        searchBar.delegate = self
    }
    // MARK: - Registration cell for collectionView
    private  func cellRegistration() {
        collectionView.register(UINib(nibName: "SearchCell", bundle: nil),
                                forCellWithReuseIdentifier: "cellectionIDCell")
    }
    // MARK: - Methods related to Activity Indicator
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
    private func gettingDataNetwork() {
        networkService.getListAlbums(searchText: searchBarText) { result in
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
    private  func extractCollectionID(indexPath: IndexPath) -> Int {
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
        if segue.identifier == "fromSearchToDetailsSegue" {
            let detailVC = segue.destination as! DetailSearchVC
            detailVC.albumID = albumID
        }
    }
    
}
// MARK: - UICollectionViewDataSource, UICollectionViewDelegate, action when selecting item
extension SearchVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albums.results?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellectionIDCell", for: indexPath) as! SearchCell
        return cell.configurateCell(collectionView: collectionView, cell: cell, dataForCell: albums, indexPath: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 150)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        albumID = self.extractCollectionID(indexPath: indexPath)
        performSegue(withIdentifier: "fromSearchToDetailsSegue", sender: nil)
    }
}
// MARK: - UISearchBarDelegate
extension SearchVC: UISearchBarDelegate, UISearchDisplayDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        do {
            try ErrorHandler.checkoutForText(searchText: searchBar.text ?? "")
            searchBarText = searchBar.text ?? ""
        } catch {
            createAlertForViewError(description: ErrorList.noTextForSearchQuery.description)
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
        self.searchBar.showsCancelButton = false
    }
}

// MARK: - Hide the keyboard, by pressing cancel
extension SearchVC {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
        self.searchBar.setShowsCancelButton(false, animated: true)
        self.albums.results = []
        self.collectionView.reloadData()
    }
}
// MARK: - Create UIAlertController For View Error
extension SearchVC {
    private func createAlertForViewError(description: String) {
        let alert = UIAlertController(title: "Error", message: description, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okButton)
        self.present(alert, animated: true)
    }
}

