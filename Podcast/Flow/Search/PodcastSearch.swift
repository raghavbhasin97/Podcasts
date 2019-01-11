import UIKit

class PodcastSearch: BaseViewController {
    fileprivate let cellId = "podcastsCell"
    private var podcasts:[Podcast] = []
    var headerString: String = "Search the largest library of podcasts by title or artist's name."
    private var isSearching = false
    lazy var tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.showsVerticalScrollIndicator = false
        let footer = UIView()
        footer.backgroundColor = .white
        table.tableFooterView = footer
        table.delegate = self
        table.dataSource = self
        table.register(PodcastCell.self, forCellReuseIdentifier: cellId)
        table.separatorInset = UIEdgeInsets(top: 0, left: 140, bottom: 0, right: 0)
        return table
    }()
    
    
    
    lazy var searchController: UISearchController = {
        let search = UISearchController(searchResultsController: nil)
        search.dimsBackgroundDuringPresentation = false
        search.searchBar.delegate = self
        search.hidesBottomBarWhenPushed = true
        return search
    }()
    
    fileprivate func setupTable() {
        view.addSubview(tableView)
        tableView.fillSuperview()
    }
    
    override func setup() {
        view.backgroundColor = .white
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        setupTable()
    }
}

//MARK:- Search Table DataSource and Delegate
extension PodcastSearch: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return podcasts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! PodcastCell
        cell.podcast = podcasts[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        return isSearching ? SearchLoadingHeader() : TextTableViewHeader(text: headerString)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return podcasts.count == 0 ? 250 : 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchController.dismiss(animated: true, completion: nil)
        let controller = EpisodesController()
        controller.podcast = podcasts[indexPath.row]
        navigationController?.pushViewController(controller, animated: true)
    }
}

//MARK:- Search Bar elegate
extension PodcastSearch: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.podcasts = []
        isSearching = true
        tableView.reloadData()
        let searchText = searchBar.text!
        if searchText.isEmpty { return }
        
        API.shared.searchPodcasts(searchText: searchText) {[unowned self] (searchedPodcasts, count) in
            self.podcasts = searchedPodcasts
            self.isSearching = false
            self.headerString = "We couldn't find any results for\n\n\"\(searchText)\"\n\nPlease try again."
            self.tableView.reloadData()
        }
        searchController.dismiss(animated: true, completion: nil)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        headerString = "Search the largest library of podcasts by title or artist's name."
        tableView.reloadData()
    }
}
