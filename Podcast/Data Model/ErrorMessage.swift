import Foundation

enum ErrorMessage: String {
    case genericError = "Something went wrong."
    case favouriteFailed = "Something went wrong while trying to favourite this prodcast"
    case removeFavouriteFailed = "Something went wrong while trying to remove this prodcast from favourites"
    case downloadFailed = "Something went wrong while trying to dowload this episode"
    case removeDownloadFailed = "Something went wrong while trying to remove this episode from downloads"
}
