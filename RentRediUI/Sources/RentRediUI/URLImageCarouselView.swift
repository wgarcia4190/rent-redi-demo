import UIKit

public final class URLImageCarouselView: UIView {

    private static let reuseIdentifier = "URLImageCarouselCell"

    private let flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = .zero
        return layout
    }()

    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .systemBackground
        cv.clipsToBounds = true
        cv.showsHorizontalScrollIndicator = false
        cv.isPagingEnabled = true
        cv.register(URLImageCarouselPhotoCell.self, forCellWithReuseIdentifier: Self.reuseIdentifier)
        cv.delegate = self
        cv.dataSource = self
        return cv
    }()

    private let pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.translatesAutoresizingMaskIntoConstraints = false
        pc.currentPageIndicatorTintColor = .white
        pc.pageIndicatorTintColor = UIColor(red: 0.784, green: 0.784, blue: 0.784, alpha: 1)
        pc.isUserInteractionEnabled = false
        return pc
    }()

    private let pageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = .white
        label.font = .systemFont(ofSize: 17)
        label.backgroundColor = UIColor(white: 0, alpha: 0.424)
        label.layer.masksToBounds = true
        return label
    }()

    private var imageURLs: [URL] = []

    public var isEmpty: Bool { imageURLs.isEmpty }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        clipsToBounds = true
        addSubview(collectionView)
        addSubview(pageControl)
        addSubview(pageLabel)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),

            pageControl.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor),
            pageControl.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),

            pageLabel.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: -10),
            pageLabel.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor, constant: -10),
            pageLabel.heightAnchor.constraint(equalTo: collectionView.heightAnchor, multiplier: 0.08),
            pageLabel.widthAnchor.constraint(equalTo: collectionView.widthAnchor, multiplier: 0.2),
        ])
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        flowLayout.invalidateLayout()
    }

    public func setImageURLs(_ urls: [URL]) {
        imageURLs = urls
        let count = urls.count
        pageControl.numberOfPages = count
        pageControl.isHidden = count <= 1
        pageLabel.isHidden = count == 0
        pageLabel.text = count > 0 ? "1 of \(count)" : nil
        collectionView.reloadData()
        guard count > 0 else { return }
        collectionView.layoutIfNeeded()
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: false)
        pageControl.currentPage = 0
    }
}

// MARK: - UICollectionViewDataSource

extension URLImageCarouselView: UICollectionViewDataSource {

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        imageURLs.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Self.reuseIdentifier, for: indexPath) as! URLImageCarouselPhotoCell
        cell.loadImage(from: imageURLs[indexPath.item])
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension URLImageCarouselView: UICollectionViewDelegateFlowLayout {

    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let w = max(collectionView.bounds.width, 1)
        let h = max(collectionView.bounds.height, 1)
        return CGSize(width: w, height: h)
    }
}

// MARK: - UICollectionViewDelegate

extension URLImageCarouselView: UICollectionViewDelegate {

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView === collectionView,
              collectionView.bounds.width > 0,
              !imageURLs.isEmpty else { return }
        let pageNumber = Int(
            (collectionView.contentOffset.x / collectionView.bounds.width).rounded(.toNearestOrAwayFromZero)
        )
        let clamped = min(max(0, pageNumber), imageURLs.count - 1)
        pageControl.currentPage = clamped
        pageLabel.text = "\(clamped + 1) of \(imageURLs.count)"
    }
}
