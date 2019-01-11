import UIKit

class EmptyFavourites: UICollectionReusableView {
    let label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15.50, weight: .semibold)
        label.textColor = .purple
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "You have not favourited any podcasts."
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setup() {
        backgroundColor = .white
        //Setup Label
        addSubview(label)
        label.fillSuperview(padding: 20)
    }
    
}
