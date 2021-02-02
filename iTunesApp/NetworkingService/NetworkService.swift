import Foundation

protocol NetworkServiceProtocol: class {
    func getListAlbums(searchText: String, completion: @escaping ((Result<AlbumsListModel, Error>) -> Void))
    func getDetailAlbum(collectionId: Int, completion: @escaping ((Result<DetailAlbumsListModel, Error>) -> Void))
}
// MARK: - Network Service for gettind data 
final class NetworkService: NetworkServiceProtocol {
    func getListAlbums(searchText: String, completion: @escaping ((Result<AlbumsListModel, Error>) -> Void)) {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "itunes.apple.com"
        urlComponents.path = "/search"
        urlComponents.queryItems = [URLQueryItem(name: "entity", value: "album"),
                                    URLQueryItem(name: "term", value: searchText)]
        guard let url = urlComponents.url else { return }
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            guard let data = data else { return }
            guard error == nil else { return }
            do {
                var albumsData: AlbumsListModel
                albumsData = try JSONDecoder().decode(AlbumsListModel.self, from: data)
                completion(.success(albumsData))
            } catch let error{
                completion(.failure(error))
            }
        }.resume()
    }
 
    func getDetailAlbum(collectionId: Int, completion: @escaping ((Result<DetailAlbumsListModel, Error>) -> Void)) {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "itunes.apple.com"
        urlComponents.path = "/lookup"
        urlComponents.queryItems = [URLQueryItem(name: "entity", value: "song"),
                                    URLQueryItem(name: "id", value: "\(collectionId)")]
        guard let url = urlComponents.url else { return }
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            guard let data = data else { return }
            guard error == nil else { return }
            do {
                var albumsData: DetailAlbumsListModel
                albumsData = try JSONDecoder().decode(DetailAlbumsListModel.self, from: data)
                completion(.success(albumsData))
            } catch let error{
                completion(.failure(error))
            }
        }.resume()
    }
}
