import UIKit

final class URLImageCarouselPhotoCell: UICollectionViewCell {

    let imageView = UIImageView()

    private var dataTask: URLSessionDataTask?
    private var pendingLoadID: UUID?

    override init(frame: CGRect) {
        super.init(frame: frame)
        install()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        install()
    }

    private func install() {
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

    /// Loads image data off the main thread and updates `imageView` on the main queue. Cancels any in-flight load when reused or when a new URL is set.
    func loadImage(from url: URL) {
        dataTask?.cancel()
        dataTask = nil

        let loadID = UUID()
        pendingLoadID = loadID
        imageView.image = nil

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self else { return }
            if let urlError = error as? URLError, urlError.code == .cancelled {
                return
            }
            guard let data, !data.isEmpty else { return }
            let image = UIImage(data: data)
            DispatchQueue.main.async {
                guard self.pendingLoadID == loadID else { return }
                self.imageView.image = image
                if image != nil {
                    self.contentView.bringSubviewToFront(self.imageView)
                }
            }
        }
        dataTask = task
        task.resume()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        dataTask?.cancel()
        dataTask = nil
        pendingLoadID = nil
        imageView.image = nil
    }
}
