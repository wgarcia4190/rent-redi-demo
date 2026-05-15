import UIKit

final class URLImageCarouselPhotoCell: UICollectionViewCell {

    let imageView = UIImageView()

    private var dataTask: URLSessionDataTask?
    private var activeLoadID: UUID?

    override init(frame: CGRect) {
        super.init(frame: frame)
        installImageView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        installImageView()
    }

    func loadImage(from url: URL) {
        cancelImageLoad()
        let loadID = UUID()
        activeLoadID = loadID
        imageView.image = nil

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self else { return }
            if let urlError = error as? URLError, urlError.code == .cancelled { return }
            guard let data, let image = UIImage(data: data) else { return }

            DispatchQueue.main.async {
                guard self.activeLoadID == loadID else { return }
                self.imageView.image = image
            }
        }
        dataTask = task
        task.resume()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        cancelImageLoad()
    }

    // MARK: - Private

    private func installImageView() {
        guard imageView.superview == nil else { return }
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        contentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }

    private func cancelImageLoad() {
        dataTask?.cancel()
        dataTask = nil
        activeLoadID = nil
        imageView.image = nil
    }
}
