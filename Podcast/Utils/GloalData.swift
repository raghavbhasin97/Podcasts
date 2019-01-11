import Foundation

//MARK:- Lists
var favourites: [Podcast] = []
var downloads: [Episode] = []

//MARK:- Contain Functions
func isFavourited(other: Podcast) -> Bool{
    for podcast in favourites {
        if podcast.isEqual(other) {
            return true
        }
    }
    return false
}

func isDownloaded(other: Episode) -> Bool{
    for episode in downloads {
        if episode.isEqual(other) {
            return true
        }
    }
    return false
}
