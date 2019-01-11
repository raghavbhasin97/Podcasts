import UIKit

class LoadingView: UIView {
    
    private let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let activity: UIActivityIndicatorView = {
        let activity = UIActivityIndicatorView(style: .whiteLarge)
        activity.color = .white
        activity.startAnimating()
        activity.translatesAutoresizingMaskIntoConstraints = false
        return activity
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupActivityIndicatorView() {
        addSubview(activity)
        centerX(item: activity)
        centerY(item: activity, constant: -20)
    }
    
    fileprivate func setupLabel() {
        addSubview(label)
        centerX(item: label)
        label.topAnchor.constraint(equalTo: activity.bottomAnchor, constant: 5).isActive = true
    }
    
    fileprivate func setup() {
        backgroundColor =  .overlayDark
        setupActivityIndicatorView()
        setupLabel()
    }
    
    override func didMoveToSuperview() {
        fillSuperview()
    }
    
    public func setPercentage(value: Double) {
        let percentage = String(Int(value))
        let attributedText = NSMutableAttributedString(attributedString: getString(text: "Downloading: ", font: 16, weight: .semibold, color: .white))
        attributedText.append(getString(text: percentage, font: 20, weight: .semibold, color: .white))
        attributedText.append(getString(text: "%", font: 20, weight: .semibold, color: .white))
        label.attributedText = attributedText
    }
}

