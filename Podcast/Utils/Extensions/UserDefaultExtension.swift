import Foundation

extension UserDefaults {
    //MARK:- Keys
    static let favouritesKey = "favouritesPodcastsKey"
    static let downloadsKey = "downloadsPodcastsKey"
    
    //MARK:- Remove element functions
    func removeFavouriteAt(index: Int) -> Bool {
        let removedPodcast = favourites.remove(at: index)
        if !saveFavourites() {
            favourites.insert(removedPodcast, at: index)
            return false
        }
        return true
    }
    
    func removeDownloadAt(index: Int) -> Bool {
        let removedEpisode = downloads.remove(at: index)
        if !saveDownloads() {
            downloads.insert(removedEpisode, at: index)
            return false
        }
        return true
    }
    
    //MARK:- Add element functions
    func addToFavourites(podcast: Podcast) -> Bool{
        favourites.append(podcast)
        if !saveFavourites() {
            _ = favourites.dropLast()
            return false
        }
        return true
    }
    
    func addToDownloads(episode: Episode) -> Bool{
        downloads.insert(episode, at: 0)
        if !saveDownloads() {
            _ = downloads.dropFirst()
            return false
        }
        return true
    }

    //MARK:- Retrieve List functions
    func retriveFavourites(){
        if let data = self.data(forKey: UserDefaults.favouritesKey) {
            do {
                favourites = try JSONDecoder().decode([Podcast].self, from: data)
            } catch let err {
                debugPrint("Retriving Failed", err)
            }
        }
    }
    
    func retriveDownloads(){
        if let data = self.data(forKey: UserDefaults.downloadsKey) {
            do {
                downloads = try JSONDecoder().decode([Episode].self, from: data)
            } catch let err {
                debugPrint("Retriving Failed", err)
            }
        }
    }
    
    //MARK:- Save List functions
    private func saveFavourites() -> Bool {
        do {
            let data = try JSONEncoder().encode(favourites)
            self.set(data, forKey: UserDefaults.favouritesKey)
        } catch let err {
            debugPrint("Saving Back Failed", err)
            return false
        }
        return true
    }
    
    private func saveDownloads() -> Bool {
        do {
            let data = try JSONEncoder().encode(downloads)
            self.set(data, forKey: UserDefaults.downloadsKey)
        } catch let err {
            debugPrint("Saving Back Failed", err)
            return false
        }
        return true
    }
    
}
