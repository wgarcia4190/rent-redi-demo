import UIKit
import RentRediUI

final class ApplyHomeVC: UIViewController {

    var tenantCardSubmission: TenantCardSubmission?
    weak var delegate: ApplyHomeVCDelegate?

    private let photoCarousel = URLImageCarouselView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let backButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureLabels()
        configureBackButton()
        configureCarousel()
        layoutContent()
        photoCarousel.setImageURLs(CarouselSampleImages.urls)
    }

    @objc private func backTapped() {
        dismiss(animated: true) { [weak self] in
            self?.delegate?.applyHomeDidDismiss()
        }
    }

    private func configureLabels() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Listing photos"
        titleLabel.font = .boldSystemFont(ofSize: 22)
        titleLabel.textAlignment = .center

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "Swipe through sample images using the reusable carousel."
        subtitleLabel.font = .preferredFont(forTextStyle: .subheadline)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
    }

    private func configureBackButton() {
        backButton.translatesAutoresizingMaskIntoConstraints = false
        var config = UIButton.Configuration.plain()
        config.title = "Back"
        config.image = UIImage(systemName: "chevron.left")
        config.imagePadding = 4
        config.baseForegroundColor = .systemBlue
        backButton.configuration = config
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
    }

    private func configureCarousel() {
        photoCarousel.translatesAutoresizingMaskIntoConstraints = false
        photoCarousel.layer.cornerRadius = 10
        photoCarousel.clipsToBounds = true
    }

    private func layoutContent() {
        let guide = view.safeAreaLayoutGuide
        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(photoCarousel)

        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: guide.topAnchor, constant: 8),
            backButton.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 16),

            titleLabel.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -24),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            photoCarousel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 24),
            photoCarousel.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 24),
            photoCarousel.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -24),
            photoCarousel.heightAnchor.constraint(equalTo: guide.heightAnchor, multiplier: 0.42),
        ])
    }
}
