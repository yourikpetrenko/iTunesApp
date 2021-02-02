//
//  HistoryVC.swift
//  iTunesApp
//
//  Created by Jura on 2/1/21.
//

import UIKit

final class HistoryVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    private var searchHistory = [String]()
    private var itemFromHistory = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.searchHistory = self.retrievningSearchHistory()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fromHistoryVCToHistoryInfo" {
            let detailSearchVC = segue.destination as! HistoryInfoVC
            detailSearchVC.itemFromHistory = itemFromHistory
        }
    }
    
    private func retrievningSearchHistory() -> [String]{
        return UserDefaults.standard.stringArray(forKey: "savedArraySearch") ?? [String]()
    }
}
// MARK: - UICollectionViewDataSource, UICollectionViewDelegate, action when selecting cell
extension HistoryVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchHistory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath)
        cell.textLabel?.text = searchHistory[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedElement = searchHistory[indexPath.row]
        itemFromHistory = selectedElement
        performSegue(withIdentifier: "fromHistoryVCToHistoryInfo", sender: nil)
    }
}
