import UIKit
import FeedKit

class EpisodesController: BaseViewController {
    fileprivate let cellId = "episodesCell"
    private var downloadProgress:LoadingView!
    var podcast: Podcast? {
        didSet {
            if let podcast = podcast {
                navigationItem.title = podcast.trackName
                setupNavigationBarButtons(isFavourite: isFavourited(other: podcast))
                API.shared.fetchEpisodesFeed(urlString: podcast.feedUrl) {[weak self] (feed) in
                    guard let feed = feed else { return }
                    self?.episodes = []
                    for item in feed.items ?? [] {
                        var newEpisode = Episode(feed: item)
                        newEpisode.artwork = podcast.largeArtwork
                        newEpisode.artworkSmall = podcast.artwork
                        self?.episodes.append(newEpisode)
                    }
                    DispatchQueue.main.async {[weak self] in
                        self?.tableView.reloadData()
                        self?.removeLoader()
                    }
                }
            }
        }
    }
    
    var episodes: [Episode] = []
    private let activity = UIActivityIndicatorView(style: .gray)
    
    lazy var tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.showsVerticalScrollIndicator = true
        let footer = UIView()
        footer.backgroundColor = .white
        table.tableFooterView = footer
        table.delegate = self
        table.dataSource = self
        table.register(EpisodeCell.self, forCellReuseIdentifier: cellId)
        return table
    }()
    
    fileprivate func setupTable() {
        view.addSubview(tableView)
        tableView.fillSuperview()
    }
    
    fileprivate func addLoader() {
        view.addSubview(activity)
        activity.fillSuperview()
        activity.startAnimating()
    }
    
    fileprivate func removeLoader() {
        view.removeConstraints(activity.constraints)
        activity.removeFromSuperview()
    }
    
    fileprivate func setupNavigationBarButtons(isFavourite: Bool) {
        //Get Fav Button
        let fav =  UIBarButtonItem(title: "Favourite", style: .plain, target: self, action: #selector(favouritePodcast))
        fav.tintColor = .purple
        //Get Heart Icon
        let heartIcon = UIBarButtonItem(image: #imageLiteral(resourceName: "heart").withRenderingMode(.alwaysTemplate), style: .plain, target: nil, action: nil)
        heartIcon.tintColor = .purple
        navigationItem.rightBarButtonItem = isFavourite ? heartIcon: fav
    }
    
    override func setup() {
        view.backgroundColor = .white
        setupTable()
        addLoader()
    }
    
    @objc fileprivate func favouritePodcast() {
        if UserDefaults.standard.addToFavourites(podcast: podcast!) {
            addedToFavourites()
        } else {
            showError(message: .favouriteFailed)
        }
        
    }
    
    fileprivate func addedToFavourites() {
        setupNavigationBarButtons(isFavourite: true)
        let main = UIApplication.shared.keyWindow?.rootViewController as! UITabBarController
        main.viewControllers?[0].tabBarItem.badgeValue = "new"
        presentConfirmation(image: #imageLiteral(resourceName: "tick"), message: "Podcast Favourited")
    }
    
    fileprivate func addedToDownloads() {
        downloadProgress.removeFromSuperview()
        let main = UIApplication.shared.keyWindow?.rootViewController as! UITabBarController
        main.viewControllers?[2].tabBarItem.badgeValue = "new"
        presentConfirmation(image: #imageLiteral(resourceName: "downloadAction"), message: "Episode Downloaded")
    }
}

//MARK:- Search Table DataSource and Delegate
extension EpisodesController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! EpisodeCell
        cell.imageUrl = podcast?.artwork
        cell.episode = episodes[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let episode = episodes[indexPath.row]
        if episode.url == nil { return }
        Player.shared.playList = episodes
        Player.shared.currentPlaying = indexPath.row
        Player.shared.epiosdeImage = podcast?.largeArtwork
        Player.shared.episode = episode
        Player.shared.maximizePlayer()
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        var episode = self.episodes[indexPath.row]
        downloadProgress = LoadingView()
        if isDownloaded(other: episode) {
            let downloadAction =
                UITableViewRowAction(style: .normal, title: "Download") {
                    (_,_) in
                    //Do Nothing Already Downloaded
            }
            return [downloadAction]
        }
        let downloadAction = UITableViewRowAction(style: .normal, title: "Download") {[unowned self] (_, _) in
            UIApplication.shared.addSubview(view: self.downloadProgress)
            API.shared.downloadEpisode(episode: episode, completion: {[weak self] (file) in
                episode.url = file
                if UserDefaults.standard.addToDownloads(episode: episode) {
                    self?.addedToDownloads()
                } else {
                    self?.showError(message: .downloadFailed)
                }
                }, progressTracker: { (completed) in
                    self.downloadProgress.setPercentage(value: completed * 100)
            })
        }
        downloadAction.backgroundColor = .optionGreen
        return [downloadAction]
    }

}
