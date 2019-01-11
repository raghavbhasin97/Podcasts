import Foundation

struct Podcast: Codable {
    
    let trackName: String
    let artistName: String
    let trackCount: Int
    let artwork: String
    let feedUrl: String
    let largeArtwork: String

    init(data: [String: Any]) {
        self.artistName = data["artistName"] as? String ?? "Unknown"
        self.trackName = data["trackName"] as? String ?? "No Title"
        self.trackCount = data["trackCount"] as? Int ?? 0
        self.artwork = data["artworkUrl100"] as? String ?? ""
        self.feedUrl = data["feedUrl"] as? String ?? ""
        self.largeArtwork = data["artworkUrl600"] as? String ?? ""
    }
    
    func isEqual(_ object: Any?) -> Bool {
        guard let otherPodcast = object as? Podcast else { return false }
        return otherPodcast.trackName == trackName && otherPodcast.artistName == artistName
    }
}

