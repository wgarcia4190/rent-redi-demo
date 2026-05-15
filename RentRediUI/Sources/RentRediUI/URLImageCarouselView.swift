import UIKit

/// Horizontal, paging image carousel with page control and "n of m" label.
public final class URLImageCarouselView: UIView {

    private enum Layout {
        static let pageLabelBottomInset: CGFloat = 10
        static let pageLabelTrailingInset: CGFloat = 10
        static let pageLabelHeightRatio: CGFloat = 0.08
        static let pageLabelWidthRatio: CGFloat = 0.2
    }

    private static let cellReuseIdentifier = "URLImageCarouselCell"

    private let flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = .zero
        return layout
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.clipsToBounds = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.register(URLImageCarouselPhotoCell.self, forCellWithReuseIdentifier: Self.cellReuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()

    private let pageControl: UIPageControl = {
        let control = UIPageControl()
        control.translatesAutoresizingMaskIntoConstraints = false
        control.currentPageIndicatorTintColor = .white
        control.pageIndicatorTintColor = UIColor(red: 0.784, green: 0.784, blue: 0.784, alpha: 1)
        control.isUserInteractionEnabled = false
        return control
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
    private var currentPageIndex = 0

    public var isEmpty: Bool { imageURLs.isEmpty }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        installSubviews()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        installSubviews()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        flowLayout.invalidateLayout()
    }

    public func setImageURLs(_ urls: [URL]) {
        imageURLs = urls
        currentPageIndex = 0
        updatePageChrome()
        collectionView.reloadData()

        guard !urls.isEmpty else { return }
        collectionView.layoutIfNeeded()
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: false)
    }

    // MARK: - Private

    private func installSubviews() {
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

            pageLabel.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: -Layout.pageLabelBottomInset),
            pageLabel.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor, constant: -Layout.pageLabelTrailingInset),
            pageLabel.heightAnchor.constraint(equalTo: collectionView.heightAnchor, multiplier: Layout.pageLabelHeightRatio),
            pageLabel.widthAnchor.constraint(equalTo: collectionView.widthAnchor, multiplier: Layout.pageLabelWidthRatio),
        ])
    }

    private func updatePageChrome() {
        let pageCount = imageURLs.count
        pageControl.numberOfPages = pageCount
        pageControl.isHidden = pageCount <= 1
        pageLabel.isHidden = pageCount == 0
        pageControl.currentPage = currentPageIndex
        pageLabel.text = pageCount > 0 ? pageLabelText(for: currentPageIndex, total: pageCount) : nil
    }

    private func pageLabelText(for pageIndex: Int, total: Int) -> String {
        "\(pageIndex + 1) of \(total)"
    }

    private func syncCurrentPageFromScrollOffset() {
        guard collectionView.bounds.width > 0, !imageURLs.isEmpty else { return }
        let rawPage = collectionView.contentOffset.x / collectionView.bounds.width
        let pageIndex = Int(rawPage.rounded(.toNearestOrAwayFromZero))
        currentPageIndex = min(max(0, pageIndex), imageURLs.count - 1)
        updatePageChrome()
    }
}

// MARK: - UICollectionViewDataSource

extension URLImageCarouselView: UICollectionViewDataSource {

    public func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        imageURLs.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: Self.cellReuseIdentifier,
            for: indexPath
        ) as! URLImageCarouselPhotoCell
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
        CGSize(
            width: max(collectionView.bounds.width, 1),
            height: max(collectionView.bounds.height, 1)
        )
    }
}

// MARK: - UICollectionViewDelegate

extension URLImageCarouselView: UICollectionViewDelegate {

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView === collectionView else { return }
        syncCurrentPageFromScrollOffset()
    }
}
