import UIKit
import Foundation
import RentRediUI

class ApartmentPopupView: UIView {

    private lazy var viewModel: ApartmentPopupViewModel = ApartmentPopupViewModel()

    weak var delegate: RentRediPlusHomeVC?
    var tenantCardSubmission: TenantCardSubmission?

    @IBOutlet weak var applicationPopupTitle: UILabel!
    @IBOutlet weak var applicationPopupBedrooms: UILabel!
    @IBOutlet weak var applicationPopupBathrooms: UILabel!
    @IBOutlet weak var applicationPopupStreetAddress: UILabel!
    @IBOutlet weak var applicationPopupRentAmount: UILabel!
    @IBOutlet weak var applicationPopupRegion: UILabel!
    @IBOutlet weak var photoCarousel: URLImageCarouselView!
    @IBOutlet weak var applicationInviteImage: UIImageView!
    @IBOutlet weak var startApplicationButton: roundedButton!

    @IBAction func startApplicationTapped(_ sender: Any) {
        delegate?.applicationPopup.isHidden = true
        delegate?.hideTenantToDoAlert()

        guard let submission = delegate?.tenantCardSubmission else { return }
        viewModel.updateInviteStatus("accepted", submission: submission)

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        switch viewModel.startApplicationFlow(for: submission) {
        case .application:
            let vc = storyboard.instantiateViewController(withIdentifier: "applyHomeScreen") as! ApplyHomeVC
            vc.modalPresentationStyle = .fullScreen
            vc.tenantCardSubmission = submission
            vc.homeVC = delegate
            delegate?.present(vc, animated: true, completion: nil)
        case .prequalification:
            let vc = storyboard.instantiateViewController(withIdentifier: "prequalifyHomeScreen") as! PrequalifyHomeVC
            vc.modalPresentationStyle = .fullScreen
            vc.tenantCardSubmission = submission
            delegate?.present(vc, animated: true, completion: nil)
        case .none:
            break
        }
    }

    @IBAction func dismissApplicationTapped(_ sender: Any) {
        if let submission = delegate?.tenantCardSubmission {
            viewModel.updateInviteStatus("viewed", submission: submission)
        }
        delegate?.applicationPopup.isHidden = true
    }

    let nibName = "ApartmentPopupView"

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    func commonInit() {
        guard let view = loadViewFromNib() else { return }
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }

    func loadViewFromNib() -> UIView? {
        let nib = UINib(nibName: nibName, bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }

    func updateViews() {
        let startButtonTitle = (delegate?.applyPrequalifyVerb(noun: tenantCardSubmission?.submissionType ?? "") ?? "").capitalizeFirstLetter()
        guard let display = viewModel.makeInviteDisplay(submission: tenantCardSubmission, startButtonTitle: startButtonTitle) else { return }

        applicationPopupTitle.text = display.titleText
        applicationPopupStreetAddress.text = display.streetAddressText
        applicationPopupRegion.text = display.regionLineText
        delegate?.hasExistingInviteApplication = true
        startApplicationButton.setTitle(display.startButtonTitle, for: .normal)
        delegate?.setupTenantToDoAlert()
        delegate?.updateToDoAlert(
            title: display.tenantToDoTitle,
            description: display.tenantToDoDescription,
            type: .applicationInvite
        )
    }

    func fetchListingDetails(ownerID: String, propertyID: String, unitID: String) {
        viewModel.fetchListingBedrooms(ownerID: ownerID, propertyID: propertyID, unitID: unitID) { [weak self] numberOfBedrooms in
            guard let self else { return }
            if numberOfBedrooms != "" {
                self.applicationPopupBedrooms.isHidden = false
                self.applicationPopupBedrooms.text = "\(numberOfBedrooms) Bedrooms"
            } else {
                self.applicationPopupBedrooms.isHidden = true
            }
        }

        viewModel.fetchListingBathrooms(ownerID: ownerID, propertyID: propertyID, unitID: unitID) { [weak self] numberOfBathrooms in
            guard let self else { return }
            if numberOfBathrooms != "" {
                self.applicationPopupBathrooms.isHidden = false
                self.applicationPopupBathrooms.text = " • \(numberOfBathrooms) Bathrooms"
            } else {
                self.applicationPopupBathrooms.isHidden = true
            }
        }

        viewModel.fetchListingMonthlyRent(ownerID: ownerID, propertyID: propertyID, unitID: unitID) { [weak self] monthlyRent in
            guard let self else { return }
            if monthlyRent != "" {
                self.applicationPopupRentAmount.isHidden = false
                self.applicationPopupRentAmount.text = "$\(monthlyRent)/month"
            } else {
                self.applicationPopupRentAmount.isHidden = true
            }
        }

        photoCarousel.setImageURLs([])
        photoCarousel.isHidden = true
        viewModel.loadListingPhotoURLs(ownerID: ownerID, propertyID: propertyID, unitID: unitID) { [weak self] urls in
            guard let self else { return }
            self.photoCarousel.setImageURLs(urls)
            self.showAndUpdateApplicationUnitAndPropertyPhotos()
        } onDefaultInvite: { [weak self] in
            guard let self else { return }
            self.showDefaultApplicationInvite()
        }
    }

    func showAndUpdateApplicationUnitAndPropertyPhotos() {
        guard !photoCarousel.isEmpty else { return }
        DispatchQueue.main.async {
            self.applicationInviteImage.isHidden = true
            self.photoCarousel.isHidden = false
            self.applicationPopupRegion.isHidden = false
        }
    }

    func showDefaultApplicationInvite() {
        DispatchQueue.main.async {
            self.applicationInviteImage.isHidden = false
            self.photoCarousel.isHidden = true
            self.applicationPopupStreetAddress.text = self.viewModel.defaultInviteStreetLine(submission: self.tenantCardSubmission)
            self.applicationPopupRegion.isHidden = true
        }
    }
}
