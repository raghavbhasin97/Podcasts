import UIKit
import FeedKit

struct Episode: Codable {
    var title: String
    var description: String
    var date: String
    var url: String?
    var author: String
    var artwork: String?
    var artworkSmall: String?
    
    init(feed: RSSFeedItem) {
        self.title = feed.title ?? "No Title"
        self.description = feed.description ?? "No Description"
        self.date = feed.pubDate?.formatDate() ?? "Unknown"
        self.url = feed.enclosure?.attributes?.url
        self.author = feed.iTunes?.iTunesAuthor ?? "Unknown"
    }
    
    func isEqual(_ object: Any?) -> Bool {
        guard let otherEpisode = object as? Episode else { return false }
        return otherEpisode.date == date && otherEpisode.title == title
    }
}
