import UIKit
import RentRediUI

final class MaintenanceRequestDetailVC: UIViewController {

    weak var delegate: MaintenanceRequestDetailVCDelegate?

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let backButton = UIButton(type: .system)
    private let titleLabel = UILabel()
    private let requestIDLabel = UILabel()
    private let statusLabel = UILabel()
    private let submittedLabel = UILabel()
    private let categoryLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let photosHeaderLabel = UILabel()
    private let photoCarousel = URLImageCarouselView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureScrollView()
        configureBackButton()
        configureLabels()
        configureCarousel()
        layoutContent()
        applySampleContent()
    }

    @objc private func backTapped() {
        dismiss(animated: true) { [weak self] in
            self?.delegate?.maintenanceRequestDetailDidDismiss()
        }
    }

    private func applySampleContent() {
        requestIDLabel.text = "Request \(MaintenanceRequestSample.requestID)"
        statusLabel.text = MaintenanceRequestSample.status
        submittedLabel.text = "Submitted \(MaintenanceRequestSample.submittedDate)"
        categoryLabel.text = MaintenanceRequestSample.category
        descriptionLabel.text = MaintenanceRequestSample.issueDescription
        photoCarousel.setImageURLs(MaintenanceRequestSample.photoURLs)
    }

    private func configureScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true

        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 12
        contentStack.alignment = .fill
    }

    private func configureBackButton() {
        backButton.translatesAutoresizingMaskIntoConstraints = false
        var config = UIButton.Configuration.plain()
        config.title = "Back"
        config.image = UIImage(systemName: "chevron.left")
        config.imagePadding = 4
        config.imagePlacement = .leading
        config.baseForegroundColor = .systemBlue
        backButton.configuration = config
        backButton.contentHorizontalAlignment = .leading
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
    }

    private func configureLabels() {
        titleLabel.text = "Maintenance Request"
        titleLabel.font = .boldSystemFont(ofSize: 22)
        titleLabel.textAlignment = .center

        requestIDLabel.font = .preferredFont(forTextStyle: .subheadline)
        requestIDLabel.textColor = .secondaryLabel
        requestIDLabel.textAlignment = .center

        statusLabel.font = .preferredFont(forTextStyle: .footnote)
        statusLabel.textColor = .white
        statusLabel.backgroundColor = .systemOrange
        statusLabel.textAlignment = .center
        statusLabel.layer.cornerRadius = 6
        statusLabel.clipsToBounds = true

        submittedLabel.font = .preferredFont(forTextStyle: .footnote)
        submittedLabel.textColor = .secondaryLabel

        categoryLabel.font = .preferredFont(forTextStyle: .headline)

        descriptionLabel.font = .preferredFont(forTextStyle: .body)
        descriptionLabel.textColor = .label
        descriptionLabel.numberOfLines = 0

        photosHeaderLabel.text = "Request photos"
        photosHeaderLabel.font = .preferredFont(forTextStyle: .headline)
    }

    private func configureCarousel() {
        photoCarousel.translatesAutoresizingMaskIntoConstraints = false
        photoCarousel.layer.cornerRadius = 10
        photoCarousel.clipsToBounds = true
    }

    private func layoutContent() {
        let guide = view.safeAreaLayoutGuide
        view.addSubview(backButton)
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        let statusContainer = UIView()
        statusContainer.addSubview(statusLabel)
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            statusLabel.topAnchor.constraint(equalTo: statusContainer.topAnchor, constant: 4),
            statusLabel.bottomAnchor.constraint(equalTo: statusContainer.bottomAnchor, constant: -4),
            statusLabel.leadingAnchor.constraint(equalTo: statusContainer.leadingAnchor, constant: 10),
            statusLabel.trailingAnchor.constraint(equalTo: statusContainer.trailingAnchor, constant: -10),
        ])

        [
            titleLabel,
            requestIDLabel,
            statusContainer,
            submittedLabel,
            categoryLabel,
            descriptionLabel,
            photosHeaderLabel,
            photoCarousel,
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentStack.addArrangedSubview($0)
        }

        contentStack.setCustomSpacing(4, after: titleLabel)
        contentStack.setCustomSpacing(16, after: descriptionLabel)

        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: guide.topAnchor, constant: 8),
            backButton.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 16),

            scrollView.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 8),
            scrollView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: guide.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 8),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 24),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -24),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -48),

            photoCarousel.heightAnchor.constraint(equalTo: guide.heightAnchor, multiplier: 0.38),
        ])
    }
}
