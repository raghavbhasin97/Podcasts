import UIKit

class Favourites: BaseViewController {
    fileprivate let cellId = "FavouritesCell"
    fileprivate let headerId = "FavouritesHeader"
    fileprivate let padding: CGFloat = 12
    fileprivate let spacing: CGFloat = 12
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collections = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collections.delegate = self
        collections.dataSource = self
        collections.backgroundColor = .white
        collections.register(FavouriteCell.self, forCellWithReuseIdentifier: cellId)
        collections.showsVerticalScrollIndicator = false
        collections.contentInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        collections.register(EmptyFavourites.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId)
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(deleteFavoutite(_:)))
        gesture.minimumPressDuration = 0.60
        collections.addGestureRecognizer(gesture)
        return collections
    }()
    
    fileprivate func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.fillSuperview()
    }
    
    override func setup() {
        view.backgroundColor = .white
        setupCollectionView()
    }
    
    @objc fileprivate func deleteFavoutite(_ gesture: UILongPressGestureRecognizer) {
        let location = gesture.location(in: collectionView)
        if let index = collectionView.indexPathForItem(at: location) {
            let item = favourites[index.item]
            let confirmation = OptionSheet(title: "Remove from Favourites!", message: "Are you sure that you want to remove \"\(item.trackName)\" from your favourites library. You will no longer have access to this podcast.")
            confirmation.addButton(image: #imageLiteral(resourceName: "delete"), title: "Remove Podcast", color: .optionRed) {
                [unowned self] in
                if UserDefaults.standard.removeFavouriteAt(index: index.item) {
                    self.collectionView.deleteItems(at: [index])
                    
                } else {
                    self.showError(message: .removeFavouriteFailed)
                }
            }
            confirmation.show()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
        self.navigationController?.tabBarItem.badgeValue = nil
    }
}

extension Favourites: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return favourites.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! FavouriteCell
        cell.podcast = favourites[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - (2 * padding + spacing ))/2
        return CGSize(width: width, height: width + 46)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) 
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return favourites.count == 0 ? CGSize(width: collectionView.frame.width, height: 400) : CGSize(width: 0, height: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = EpisodesController()
        controller.podcast = favourites[indexPath.row]
        navigationController?.pushViewController(controller, animated: true)
    }
}
