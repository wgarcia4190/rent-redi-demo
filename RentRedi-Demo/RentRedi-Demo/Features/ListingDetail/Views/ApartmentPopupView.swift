import UIKit
import RentRediUI

final class ApartmentPopupView: UIView {

    private let viewModel: ApartmentPopupViewModel
    private let nibName = "ApartmentPopupView"

    weak var delegate: ApartmentPopupViewDelegate?
    var tenantCardSubmission: TenantCardSubmission?

    @IBOutlet private weak var applicationPopupTitle: UILabel!
    @IBOutlet private weak var applicationPopupBedrooms: UILabel!
    @IBOutlet private weak var applicationPopupBathrooms: UILabel!
    @IBOutlet private weak var applicationPopupStreetAddress: UILabel!
    @IBOutlet private weak var applicationPopupRentAmount: UILabel!
    @IBOutlet private weak var applicationPopupRegion: UILabel!
    @IBOutlet private weak var photoCarousel: URLImageCarouselView!
    @IBOutlet private weak var applicationInviteImage: UIImageView!
    @IBOutlet private weak var startApplicationButton: roundedButton!

    init(frame: CGRect, viewModel: ApartmentPopupViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
        loadContentFromNib()
    }

    override init(frame: CGRect) {
        self.viewModel = ApartmentPopupViewModel()
        super.init(frame: frame)
        loadContentFromNib()
    }

    required init?(coder: NSCoder) {
        self.viewModel = ApartmentPopupViewModel()
        super.init(coder: coder)
        loadContentFromNib()
    }

    @IBAction private func startApplicationTapped(_ sender: Any) {
        guard let submission = delegate?.tenantCardSubmission else { return }
        delegate?.hideApplicationPopup()
        delegate?.hideTenantToDoAlert()
        viewModel.markInviteAccepted(submission: submission)

        switch viewModel.applicationFlow(for: submission) {
        case .application:
            delegate?.presentApplyHome(for: submission)
        case .prequalification:
            delegate?.presentPrequalifyHome(for: submission)
        case .none:
            break
        }
    }

    @IBAction private func dismissApplicationTapped(_ sender: Any) {
        if let submission = delegate?.tenantCardSubmission {
            viewModel.markInviteViewed(submission: submission)
        }
        delegate?.hideApplicationPopup()
    }

    func updateViews() {
        let noun = tenantCardSubmission?.submissionType ?? ""
        let startButtonTitle = (delegate?.applyPrequalifyVerb(noun: noun) ?? "").capitalizeFirstLetter()
        guard let display = viewModel.makeInviteDisplay(submission: tenantCardSubmission, startButtonTitle: startButtonTitle) else {
            return
        }

        applicationPopupTitle.text = display.titleText
        applicationPopupStreetAddress.text = display.streetAddressText
        applicationPopupRegion.text = display.regionLineText
        startApplicationButton.setTitle(display.startButtonTitle, for: .normal)

        delegate?.hasExistingInviteApplication = true
        delegate?.setupTenantToDoAlert()
        delegate?.updateToDoAlert(
            title: display.tenantToDoTitle,
            description: display.tenantToDoDescription,
            type: .applicationInvite
        )
    }

    func fetchListingDetails(for unit: TenantCardSubmission.ListingUnitReference) {
        resetPhotoCarousel()

        viewModel.fetchListingDetails(
            for: unit,
            onBedrooms: { [weak self] value in
                self?.applyListingLabel(
                    self?.applicationPopupBedrooms,
                    value: value,
                    visibleFormat: "%@ Bedrooms"
                )
            },
            onBathrooms: { [weak self] value in
                self?.applyListingLabel(
                    self?.applicationPopupBathrooms,
                    value: value,
                    visibleFormat: " • %@ Bathrooms"
                )
            },
            onMonthlyRent: { [weak self] value in
                self?.applyListingLabel(
                    self?.applicationPopupRentAmount,
                    value: value,
                    visibleFormat: "$%@/month"
                )
            },
            onPhotoURLs: { [weak self] urls in
                self?.showPhotoCarousel(urls: urls)
            },
            onNoPhotos: { [weak self] in
                self?.showDefaultInvitePlaceholder()
            }
        )
    }

    // MARK: - Private

    private func loadContentFromNib() {
        guard let contentView = UINib(nibName: nibName, bundle: nil)
            .instantiate(withOwner: self, options: nil)
            .first as? UIView else { return }
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(contentView)
    }

    private func resetPhotoCarousel() {
        photoCarousel.setImageURLs([])
        photoCarousel.isHidden = true
    }

    private func applyListingLabel(_ label: UILabel?, value: String, visibleFormat: String) {
        guard let label else { return }
        let hasValue = !value.isEmpty
        label.isHidden = !hasValue
        label.text = hasValue ? String(format: visibleFormat, value) : nil
    }

    private func showPhotoCarousel(urls: [URL]) {
        guard !urls.isEmpty else { return }
        photoCarousel.setImageURLs(urls)
        applicationInviteImage.isHidden = true
        photoCarousel.isHidden = false
        applicationPopupRegion.isHidden = false
    }

    private func showDefaultInvitePlaceholder() {
        applicationInviteImage.isHidden = false
        photoCarousel.isHidden = true
        applicationPopupStreetAddress.text = viewModel.defaultInviteStreetLine(submission: tenantCardSubmission)
        applicationPopupRegion.isHidden = true
    }
}
