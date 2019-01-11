import UIKit
import AVKit
import MediaPlayer

protocol PlayerDelegate {
    func minimize()
    func maximize()
}

class Player: UIView {
    
    public static let shared = Player()
    fileprivate let roundRadius: CGFloat = 5.0
    fileprivate let outterPadding: CGFloat = 20
    fileprivate let iconSize: CGFloat = 24
    fileprivate let scaleDown: CGFloat = 0.75
    private let player = AVPlayer()
    private var duration: Float64 = 0.0
    private var titleHeightConstraint: NSLayoutConstraint!
    var delegate: PlayerDelegate!
    var playList: [Episode] = []
    var currentPlaying: Int = 0
    var episode: Episode? {
        didSet {
            if let episode = episode {
                clearView()
                player.pause()
                setupLabel(title, episode.title)
                setupLabel(author, episode.author)
                startPlaying()
                miniTitle.text = episode.title
            }
        }
    }
    var epiosdeImage: String? {
        didSet {
            if let epiosdeImage = epiosdeImage {
                episodeImage.downloadImage(url: epiosdeImage)
                miniImage.downloadImage(url: epiosdeImage)
                episodeImage.transform = CGAffineTransform(scaleX: scaleDown, y: scaleDown)
            }
        }
    }
    
    
    fileprivate func clearView() {
        episodeImage.image =  #imageLiteral(resourceName: "blankPodcast")
        if titleHeightConstraint != nil {
            title.removeConstraint(titleHeightConstraint)
        }
        playButton.setImage(#imageLiteral(resourceName: "pause").withRenderingMode(.alwaysTemplate), for: .normal)
        miniPlay.setImage(#imageLiteral(resourceName: "pause").withRenderingMode(.alwaysTemplate), for: .normal)
        currentTime.text = "00:00"
        totalTime.text = "--:--"
    }
    
    
    init() {
        super.init(frame: UIScreen.main.bounds)
        setup()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var dissmissButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Dissmiss", for: .normal)
        button.widthAnchor.constraint(equalToConstant: frame.width - 2*outterPadding).isActive = true
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        button.addTarget(self, action: #selector(dissmiss), for: .touchUpInside)
        button.setTitleColor(.hotBlack, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        return button
    }()
    
    lazy var episodeImage: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "blankPodcast"))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = roundRadius
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1).isActive = true
        return imageView
    }()
    
    lazy var currentTime: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.heightAnchor.constraint(equalToConstant: 20).isActive = true
        return label
    }()
    
    lazy var totalTime: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textAlignment = .right
        label.heightAnchor.constraint(equalToConstant: 20).isActive = true
        return label
    }()
    
    lazy var timeStack: UIStackView = {
        let dummyView1 = UIView()
        dummyView1.widthAnchor.constraint(equalToConstant: iconSize/4).isActive = true
        let stack = UIStackView(arrangedSubviews: [currentTime, totalTime])
        stack.axis = .horizontal
        stack.distribution = .fill
        return stack
    }()
    
    lazy var progressSlider: UISlider = {
        let slider = UISlider()
        slider.heightAnchor.constraint(equalToConstant: 36).isActive = true
        slider.addTarget(self, action: #selector(changeTime(_:)), for: .valueChanged)
        return slider
    }()
    
    lazy var title: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width - 2*outterPadding, height: CGFloat.greatestFiniteMagnitude))
        label.textAlignment = .left
        label.textColor = .black
        label.font = .systemFont(ofSize: 16.5, weight: .semibold)
        label.numberOfLines = 0
        return label
    }()
    
    lazy var author: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width - 2*outterPadding, height: CGFloat.greatestFiniteMagnitude))
        label.textAlignment = .left
        label.textColor = .purple
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        return label
    }()
    
    lazy var playButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "pause").withRenderingMode(.alwaysTemplate), for: .normal)
        button.addTarget(self, action: #selector(play), for: .touchUpInside)
        button.tintColor = .black
        return button
    }()
    
    lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "backward").withRenderingMode(.alwaysTemplate), for: .normal)
        button.addTarget(self, action: #selector(backward), for: .touchUpInside)
        button.tintColor = .black
        return button
    }()
    
    lazy var forwardButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "forward").withRenderingMode(.alwaysTemplate), for: .normal)
        button.addTarget(self, action: #selector(forward), for: .touchUpInside)
        button.tintColor = .black
        return button
    }()
    
    lazy var controlsStack: UIStackView = {
        let dummyView1 = UIView()
        let dummyView2 = UIView()
        let dummyView3 = UIView()
        let dummyView4 = UIView()
        
        let stack = UIStackView(arrangedSubviews: [dummyView1, backButton, dummyView2, playButton, dummyView3, forwardButton, dummyView4])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        return stack
    }()
    
    lazy var volumeDown: UIImageView = {
        let image = UIImageView(image: #imageLiteral(resourceName: "volumeDown").withRenderingMode(.alwaysTemplate))
        image.widthAnchor.constraint(equalToConstant: iconSize).isActive = true
        image.heightAnchor.constraint(equalToConstant: iconSize).isActive = true
        image.tintColor = UIColor.hotBlack.withAlphaComponent(0.75)
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    lazy var volumeUp: UIImageView = {
        let image = UIImageView(image: #imageLiteral(resourceName: "volumeUp").withRenderingMode(.alwaysTemplate))
        image.widthAnchor.constraint(equalToConstant: iconSize).isActive = true
        image.tintColor = UIColor.hotBlack.withAlphaComponent(0.75)
        image.heightAnchor.constraint(equalToConstant: iconSize).isActive = true
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    lazy var volumeSlider: UISlider = {
        let slider = UISlider()
        slider.value = 1.0
        slider.addTarget(self, action: #selector(changeVolume(_:)), for: .touchUpInside)
        return slider
    }()
    
    lazy var volumeStack: UIStackView = {
        let dummyView1 = UIView()
        dummyView1.widthAnchor.constraint(equalToConstant: iconSize/4).isActive = true
        let stack = UIStackView(arrangedSubviews: [volumeDown, volumeSlider, dummyView1, volumeUp])
        stack.axis = .horizontal
        stack.distribution = .fill
        return stack
    }()
    
    lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [dissmissButton, episodeImage,  progressSlider, timeStack, title, author, controlsStack, volumeStack])
        stack.axis = .vertical
        stack.backgroundColor = .white
        return stack
    }()
    
    fileprivate func setupMainStack() {
        stackView.alpha = 0
        addSubview(stackView)
        stackView.fillSuperview(padding: outterPadding)
        stackView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleMaximizedPan(_:))))
    }
    
    fileprivate func setupAudioPlayback() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .allowAirPlay)
            try AVAudioSession.sharedInstance().setActive(true, options: AVAudioSession.SetActiveOptions.notifyOthersOnDeactivation)
        } catch let err {
            print(err)
        }
    }
    
    fileprivate func setup() {
        backgroundColor = .white
        setupMainStack()
        setupMiniPlayer()
        NotificationCenter.default.addObserver(self, selector: #selector(playerStalled), name: NSNotification.Name.AVPlayerItemPlaybackStalled, object: nil)
        setupAudioPlayback()
        let commandCenter =  MPRemoteCommandCenter.shared()
        enableCommandCenter(commands: [
                commandCenter.togglePlayPauseCommand: play,
                commandCenter.nextTrackCommand: nextTrack,
                commandCenter.previousTrackCommand: previousTrack
        ])
    }
    
    fileprivate func enableCommandCenter(commands: [MPRemoteCommand: () -> Void]) {
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        commands.forEach { (command, action) in
            command.isEnabled = true
            command.addTarget { (_) -> MPRemoteCommandHandlerStatus in
                action()
                return .success
            }
        }
    }
    
    fileprivate func setupLabel(_ label: UILabel, _ text: String) {
        label.text = text
        label.sizeToFit()
        if label == title {
            titleHeightConstraint = label.heightAnchor.constraint(equalToConstant: label.frame.height + 10)
            titleHeightConstraint.isActive = true
        } else {
            label.heightAnchor.constraint(equalToConstant: label.frame.height + 10).isActive = true
        }
    }
    
    fileprivate func startPlaying() {
        guard let url = generateAudioURL(from:  episode?.url ?? "") else { return }
        let item = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: item)
        player.automaticallyWaitsToMinimizeStalling = false
        player.play()
        playerBuffered()
        trackProgress()
    }
    
    fileprivate func enlargeImage() {
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            [unowned self] in
            self.episodeImage.transform = .identity
        })
    }
    
    fileprivate func contractImage() {
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
           [unowned self] in
            self.episodeImage.transform = CGAffineTransform(scaleX: self.scaleDown, y: self.scaleDown)
        })
    }

    @objc fileprivate func dissmiss() {
      delegate.minimize()
    }
    
    @objc fileprivate func play() {
        if player.timeControlStatus == .paused {
            playButton.setImage(#imageLiteral(resourceName: "pause").withRenderingMode(.alwaysTemplate), for: .normal)
            enlargeImage()
            player.play()
            miniPlay.setImage(#imageLiteral(resourceName: "pause").withRenderingMode(.alwaysTemplate), for: .normal)
        } else {
            playButton.setImage(#imageLiteral(resourceName: "playButton").withRenderingMode(.alwaysTemplate), for: .normal)
            player.pause()
            contractImage()
            miniPlay.setImage(#imageLiteral(resourceName: "playButton").withRenderingMode(.alwaysTemplate), for: .normal)
        }
    }
    
    @objc fileprivate func handleMaximizedPan(_ gesture: UIPanGestureRecognizer) {
        if gesture.state == .changed {
            let translation = gesture.translation(in: superview)
            if translation.y < 0{ return }
            self.transform = CGAffineTransform(translationX: 0, y: translation.y)
            self.stackView.alpha = 1 + translation.y/200
            self.miniPlayer.alpha = -translation.y/200
        } else if gesture.state == .ended {
            let translation = gesture.translation(in: superview)
            let velocity = gesture.velocity(in: superview)
            if translation.y > 200 || (velocity.y > 500 && translation.y < 200) {
                dissmiss()
                return
            }
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.transform = .identity
                self.miniPlayer.alpha = 0
                self.stackView.alpha = 1
            })
        }
    }
    
    @objc fileprivate func forward() {
        seekTo(delta: 10)
    }
    
    @objc fileprivate func backward() {
       seekTo(delta: -10)
    }
    
    @objc fileprivate func changeVolume(_ slider: UISlider) {
        player.volume = slider.value
    }
    
    fileprivate func seekTo(delta: Int64) {
        let seconds = CMTimeMake(value: delta, timescale: 1)
        let seekTime = CMTimeAdd(player.currentTime(), seconds)
        player.seek(to: seekTime)
    }
    
    @objc fileprivate func changeTime(_ slider: UISlider) {
        let newProgress = slider.value
        let newValue = Float64(newProgress) * duration
        let newTime = CMTimeMakeWithSeconds(newValue, preferredTimescale: Int32(NSEC_PER_SEC))
        player.seek(to: newTime)
    }
    
    fileprivate func playerBuffered() {
        let time = CMTimeMake(value: 1, timescale: 3)
        player.addBoundaryTimeObserver(forTimes: [NSValue(time: time)], queue: .main) {[unowned self] in
            
            self.duration = CMTimeGetSeconds((self.player.currentItem?.duration)!)
            self.totalTime.text  = self.duration.formatDuration()
            self.enlargeImage()
            
            var info =  MPNowPlayingInfoCenter.default().nowPlayingInfo
            if info == nil {
                info = [String: Any]()
            }
            info?[MPMediaItemPropertyTitle] = self.episode?.title
            info?[MPMediaItemPropertyArtist] = self.episode?.author
            info?[MPMediaItemPropertyAlbumArtist] = self.episode?.author
            info?[MPMediaItemPropertyPlaybackDuration] = self.duration
            let tempIv = UIImageView()
            tempIv.downloadImage(url: self.episode?.artwork ?? "") { (image) in
                if let image = image {
                    let artwork = MPMediaItemArtwork(boundsSize: image.size, requestHandler: { (_) -> UIImage in
                        return image
                    })
                    info?[MPMediaItemPropertyArtwork] = artwork
                    MPNowPlayingInfoCenter.default().nowPlayingInfo = info
                }
            }
        }
    }
    
    fileprivate func trackProgress() {
        let time = CMTimeMake(value: 1, timescale: 2)
        player.addPeriodicTimeObserver(forInterval: time, queue: .main) {[weak self] (current) in
            let seconds = CMTimeGetSeconds(current)
            self?.currentTime.text  = seconds.formatDuration()
            self?.updateProgressSlider(current: seconds)
            MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = seconds
        }
    }
    
    fileprivate func updateProgressSlider(current: Float64) {
        let ratio = current/duration
        progressSlider.setValue(Float(ratio), animated: true)
    }
    
    @objc public func maximizePlayer() {
        delegate.maximize()
    }
    
    @objc fileprivate func playerStalled() {
        playButton.setImage(#imageLiteral(resourceName: "playButton").withRenderingMode(.alwaysTemplate), for: .normal)
        contractImage()
    }
    
    //MARK:- MINI Player
    lazy var miniPlayer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addLine(position: .Top)
        return view
    }()
    
    lazy var miniTitle: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .black
        label.font = .systemFont(ofSize: 14.5, weight: .semibold)
        return label
    }()
    
    lazy var miniImage: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "blankPodcast"))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = roundRadius
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1).isActive = true
        return imageView
    }()
    
    lazy var miniPlay: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "pause").withRenderingMode(.alwaysTemplate), for: .normal)
        button.addTarget(self, action: #selector(play), for: .touchUpInside)
        button.tintColor = .black
        button.widthAnchor.constraint(equalToConstant: 64).isActive = true
        return button
    }()
    
    lazy var miniStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [miniImage, miniTitle, miniPlay])
        stack.axis = .horizontal
        stack.spacing = 5.0
        return stack
    }()
    
    fileprivate func setupMiniPlayer() {
        insertSubview(miniPlayer, aboveSubview: stackView)
        miniPlayer.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        miniPlayer.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        miniPlayer.topAnchor.constraint(equalTo: topAnchor).isActive = true
        miniPlayer.heightAnchor.constraint(equalToConstant: 64).isActive = true
        setupStack()
        miniPlayer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(maximizePlayer)))
        miniPlayer.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleMinimizedPan(_:))))
    }
    
    @objc fileprivate func handleMinimizedPan(_ gesture: UIPanGestureRecognizer) {
        if gesture.state == .ended {
            let velocity = gesture.velocity(in: superview)
            if velocity.y < -500 {
                maximizePlayer()
                return
            }
        }
    }
    
    fileprivate func setupStack() {
        miniPlayer.addSubview(miniStack)
        miniStack.fillSuperview(padding: 6.5)
    }
    
    fileprivate func nextTrack() {
        currentPlaying += 1
        if currentPlaying >= playList.count {
            currentPlaying = 0
        }
        episode = playList[currentPlaying]
        self.epiosdeImage = episode?.artwork
    }
    
    fileprivate func previousTrack() {
        currentPlaying -= 1
        if currentPlaying < 0 {
            currentPlaying = playList.count - 1
        }
        episode = playList[currentPlaying]
        self.epiosdeImage = episode?.artwork
    }
}
