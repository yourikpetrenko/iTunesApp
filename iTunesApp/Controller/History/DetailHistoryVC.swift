//
//  DetailHistoryVC.swift
//  iTunesApp
//
//  Created by Jura on 2/1/21.
//

import UIKit

final class DetailHistoryVC: UIViewController {
    
    @IBOutlet weak var albumImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var albumNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private let networkService: NetworkServiceProtocol = NetworkService()
    private var detailAlbum: DetailAlbumsListModel?
    var albumID = Int() {
        didSet {
            getDetailAlbum()
        }
    }
    private var infoForHeadAlbum: DetailAlbumModel?
    private var trackList = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDelegate()
        self.activityIndicatorStartAnimating()
    }
    // MARK: - Setup Delegate, DataSource
    private func setupDelegate() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    // MARK: - Methods related to Activity Indicator
    private func activityIndicatorStartAnimating() {
        DispatchQueue.main.async {
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
        }
    }
    private func activityIndicatorIsHidden() {
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true
    }
    
    // MARK: - Getting detail album from Network
    private func getDetailAlbum() {
        networkService.getDetailAlbum(collectionId: albumID) { result in
            switch result {
            case .success(let albumData):
                self.detailAlbum = albumData
                self.setup()
            case .failure(let error):
                self.createAlertForViewError(description: error.localizedDescription)
            }
        }
    }
    // MARK: - Setup value
    private func setup() {
        self.infoForHeadAlbum = self.extractNecessaryDataFrom(data: self.detailAlbum, wrapperType: "collection")
        self.trackList = self.extractTrackListFrom(detailAlbum: self.detailAlbum)
        self.updateInterface(infoForHeadAlbum: infoForHeadAlbum)
        DispatchQueue.main.async {
            self.activityIndicatorIsHidden()
            self.tableView.reloadData()
        }
    }
    // MARK: - Methods for sorting the received data
    private func extractNecessaryDataFrom(data: DetailAlbumsListModel?, wrapperType: String) -> DetailAlbumModel? {
        var currentAlbum: DetailAlbumModel?
        if let albumInfo = data?.results?.filter({$0.wrapperType == wrapperType }) {
            currentAlbum = albumInfo[0]
        }
        return currentAlbum
    }
    
    private func extractTrackListFrom(detailAlbum: DetailAlbumsListModel?) -> [String] {
        var trackList = [String]()
        if let tracks = detailAlbum?.results?.filter({$0.wrapperType == "track" }) {
            trackList = tracks.compactMap{$0.trackName}
        }
        return trackList
    }
    // MARK: - Update Interface after gettind data
    private func updateInterface(infoForHeadAlbum: DetailAlbumModel?) {
        guard let infoForHeadAlbum = infoForHeadAlbum else { return }
        guard let imageURL = URL(string: infoForHeadAlbum.artworkUrl60) else { return }
        guard let imageData = try? Data(contentsOf: imageURL) else { return }
        DispatchQueue.main.async {
            self.albumImage.image = UIImage(data: imageData)
            self.albumNameLabel.text = infoForHeadAlbum.collectionName
            self.artistNameLabel.text = infoForHeadAlbum.artistName
        }
    }
}
// MARK: - UITableViewDelegate, UITableViewDataSource
extension DetailHistoryVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trackList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "trackCell", for: indexPath)
        cell.textLabel?.text = trackList[indexPath.row]
        return cell
    }
}
// MARK: - Create UIAlertController For View Error
extension DetailHistoryVC {
    private func createAlertForViewError(description: String) {
        let alert = UIAlertController(title: "Error", message: description, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okButton)
        self.present(alert, animated: true)
    }
}
