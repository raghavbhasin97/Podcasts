import UIKit

class Main: UITabBarController {

    private var maximizedConstraint: NSLayoutConstraint!
    private var minimizedConstraint: NSLayoutConstraint!
    private var colapsedConstraint: NSLayoutConstraint!
    private var coverHeight: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    public let player = Player.shared
    //MARK:- Setup
    fileprivate func setup() {
        let favourites = getController(root: Favourites(), selectedImage: #imageLiteral(resourceName: "playSelected"), image: #imageLiteral(resourceName: "play"), title: "Favourites")
        let search = getController(root: PodcastSearch(), selectedImage: #imageLiteral(resourceName: "searchSelected"), image: #imageLiteral(resourceName: "search"), title: "Search")
        let downloads = getController(root: Downloads(), selectedImage: #imageLiteral(resourceName: "downloadSelected"), image: #imageLiteral(resourceName: "download"), title: "Downloads")
        viewControllers = [favourites, search, downloads]
        addPlayer()
        UserDefaults.standard.retriveFavourites()
        UserDefaults.standard.retriveDownloads()
    }
    
    //MARK:- Functions
    func getController(root: UIViewController, selectedImage: UIImage, image: UIImage, title: String?) -> UIViewController {
        let controller = UINavigationController(rootViewController: root)
        root.navigationItem.title = title
        controller.tabBarItem.title = title
        controller.tabBarItem.selectedImage = selectedImage.withRenderingMode(.alwaysTemplate)
        controller.tabBarItem.image = image.withRenderingMode(.alwaysTemplate)
        return controller
    }
    
    fileprivate func addPlayer() {
        player.delegate = self
        player.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(player, belowSubview: tabBar)
        player.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        player.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        player.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        maximizedConstraint = player.topAnchor.constraint(equalTo: view.topAnchor)
        minimizedConstraint = player.topAnchor.constraint(equalTo: tabBar.topAnchor, constant: -64)
        colapsedConstraint = player.topAnchor.constraint(equalTo: tabBar.bottomAnchor)
        colapsedConstraint.isActive = true
    }
}

//MARK:- Player Controlls
extension Main: PlayerDelegate {
    func minimize() {
        colapsedConstraint.isActive = false
        maximizedConstraint.isActive = false
        minimizedConstraint.isActive = true
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            [unowned self] in
            self.view.layoutIfNeeded()
            self.tabBar.transform = .identity
            self.player.miniPlayer.alpha = 1
            self.player.stackView.alpha = 0
            self.player.transform = .identity
        })
    }
    
    func maximize() {
        colapsedConstraint.isActive = false
        maximizedConstraint.isActive = true
        minimizedConstraint.isActive = false
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            [unowned self] in
            self.view.layoutIfNeeded()
            self.tabBar.transform = CGAffineTransform(translationX: 0, y: 100)
            self.player.miniPlayer.alpha = 0
            self.player.stackView.alpha = 1
        })
    }
    
    
}
