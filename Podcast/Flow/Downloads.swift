import UIKit

class Downloads: BaseViewController {
    
    fileprivate let cellId = "DownloadsCell"
    
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
    
    override func setup() {
        view.backgroundColor = .white
        setupTable()
    }
    
    @objc fileprivate func updateDownloads() {
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        self.navigationController?.tabBarItem.badgeValue = nil
    }
    
    fileprivate func deleteAction(at: IndexPath, url: String) {
        tableView.deleteRows(at: [at], with: .automatic)
        presentConfirmation(image: #imageLiteral(resourceName: "tick"), message: "Episode Deleted")
        if let fileUrl = generateAudioURL(from: url) {
            do {
                try FileManager.default.removeItem(at: fileUrl)
                debugPrint("Deleted local audio file: ", fileUrl.absoluteString)
            }
            catch let err {
                debugPrint("Removing Failed: ", err)
            }
        }
    }
}

extension Downloads: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return downloads.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! EpisodeCell
        let episode = downloads[indexPath.row]
        cell.episode = episode
        cell.imageUrl = episode.artworkSmall
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        return TextTableViewHeader(text: "You have not downloaded any podcasts.")
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return downloads.count == 0 ? 250 : 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let episode = downloads[indexPath.row]
        if episode.url == nil { return }
        Player.shared.playList = downloads
        Player.shared.currentPlaying = indexPath.row
        Player.shared.epiosdeImage = episode.artwork
        Player.shared.episode = episode
        Player.shared.maximizePlayer()
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let item = downloads[indexPath.row]
        let downloadAction = UITableViewRowAction(style: .normal, title: "Delete") {[unowned self] (_, index) in
            
             let confirmation = OptionSheet(title: "Remove from Downloads!", message: "Are you sure that you want to remove \"\(item.title)\" from your downloads library. You will no longer have access to this podcast.")
            confirmation.addButton(image: #imageLiteral(resourceName: "delete"), title: "Remove Episode", color: .optionRed) {
                [unowned self] in
                if UserDefaults.standard.removeDownloadAt(index: index.row){
                    self.deleteAction(at: index, url: item.url ?? "")
                } else {
                    self.showError(message: .removeDownloadFailed)
                }
            }
            confirmation.show()
        }
        downloadAction.backgroundColor = .optionRed
        return [downloadAction]
    }
}
