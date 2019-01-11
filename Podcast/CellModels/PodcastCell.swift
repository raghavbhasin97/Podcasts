import UIKit

class PodcastCell: BaseTableViewCell {
    fileprivate let imageSize: CGFloat = 100
    fileprivate let roundRadius: CGFloat = 5.0
    
    var podcast: Podcast? {
        didSet {
            if let podcast = podcast {
                podcastImage.downloadImage(url: podcast.artwork)
                let attributedText = NSMutableAttributedString(attributedString: getString(text: podcast.trackName + "\n", font: 16.5, weight: .semibold, color: .hotBlack))
                attributedText.append(getString(text: podcast.artistName + "\n", font: 14.25, weight: .regular, color: .hotGray))
                attributedText.append(getString(text: "\n", font: 5, weight: .regular, color: .hotBlack))
                attributedText.append(getString(text: String(podcast.trackCount) + " Episode" + (podcast.trackCount == 1 ?  "" : "s"), font: 13.25, weight: .regular, color: .purple))
                infoLabel.attributedText = attributedText
               
            }
        }
    }
    
    lazy var podcastImage: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "blankPodcast"))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = roundRadius
        return imageView
    }()
    
    let infoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    fileprivate func setupImageView() {
        addSubview(podcastImage)
        podcastImage.widthAnchor.constraint(equalToConstant: imageSize).isActive = true
        podcastImage.heightAnchor.constraint(equalToConstant: imageSize).isActive = true
        addConstraintsWithFormat(format: "V:|-15-[v0]-15-|", views: podcastImage)
        podcastImage.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
    }
    
    fileprivate func setupInfoLabel() {
        addSubview(infoLabel)
        centerY(item: infoLabel)
        infoLabel.leftAnchor.constraint(equalTo: podcastImage.rightAnchor, constant: 20).isActive = true
        infoLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
    }
    
    override func setup() {
        backgroundColor = .white
        setupImageView()
        setupInfoLabel()
    }
}
