import UIKit
import Foundation

class ApartmentPopupView: UIView {

    private let apartmentPhotoReuseIdentifier = "apartmentPhotoCell"

    private lazy var viewModel: ApartmentPopupViewModel = ApartmentPopupViewModel()

    weak var delegate: RentRediPlusHomeVC?
    var applicationPhotosUrls = [URL]()
    var tenantCardSubmission: TenantCardSubmission?

    @IBOutlet weak var applicationPopupTitle: UILabel!
    @IBOutlet weak var applicationPopupBedrooms: UILabel!
    @IBOutlet weak var applicationPopupBathrooms: UILabel!
    @IBOutlet weak var applicationPopupStreetAddress: UILabel!
    @IBOutlet weak var applicationPopupRentAmount: UILabel!
    @IBOutlet weak var applicationPopupRegion: UILabel!
    @IBOutlet weak var applicationPopupPhotos: UICollectionView!
    @IBOutlet weak var applicationInviteImage: UIImageView!
    @IBOutlet weak var applicationPopupPageNumber: UILabel!
    @IBOutlet weak var applicationPhotoDots: UIPageControl!
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
        wireUpPhotosCollectionView()
    }

    private func wireUpPhotosCollectionView() {
        applicationPopupPhotos.delegate = self
        applicationPopupPhotos.dataSource = self
        applicationPopupPhotos.register(
            ApplicationApartmentPhotoCell.self,
            forCellWithReuseIdentifier: apartmentPhotoReuseIdentifier
        )
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

        applicationPhotosUrls = []
        viewModel.loadListingPhotoURLs(ownerID: ownerID, propertyID: propertyID, unitID: unitID) { [weak self] urls in
            guard let self else { return }
            self.applicationPhotosUrls = urls
            self.showAndUpdateApplicationUnitAndPropertyPhotos()
        } onDefaultInvite: { [weak self] in
            guard let self else { return }
            self.showDefaultApplicationInvite()
        }
    }

    func showAndUpdateApplicationUnitAndPropertyPhotos() {
        if !applicationPhotosUrls.isEmpty {
            DispatchQueue.main.async {
                self.applicationPhotoDots.isHidden = false
                self.applicationPopupPhotos.isHidden = false
                self.applicationPopupRegion.isHidden = false
                self.applicationPopupPhotos.reloadData()
                self.applicationPopupPageNumber.text = "1 of \(self.applicationPhotosUrls.count)"
            }
        }
    }

    func showDefaultApplicationInvite() {
        DispatchQueue.main.async {
            self.applicationInviteImage.isHidden = false
            self.applicationPhotoDots.isHidden = true
            self.applicationPopupPhotos.isHidden = true
            self.applicationPopupPageNumber.isHidden = true
            self.applicationPopupStreetAddress.text = self.viewModel.defaultInviteStreetLine(submission: self.tenantCardSubmission)
            self.applicationPopupRegion.isHidden = true
        }
    }
}

// MARK: - UICollectionViewDataSource

extension ApartmentPopupView: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == applicationPopupPhotos {
            applicationPhotoDots.numberOfPages = applicationPhotosUrls.count
            return applicationPhotosUrls.count
        }
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == applicationPopupPhotos {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: apartmentPhotoReuseIdentifier, for: indexPath) as! ApplicationApartmentPhotoCell

            let url = applicationPhotosUrls[indexPath.row]
            let data = try? Data(contentsOf: url)
            if let imageData = data {
                cell.apartmentPhoto.image = UIImage(data: imageData)
                cell.bringSubviewToFront(cell.apartmentPhoto)
            }

            return cell
        }
        return collectionView.dequeueReusableCell(withReuseIdentifier: apartmentPhotoReuseIdentifier, for: indexPath) as! ApplicationApartmentPhotoCell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ApartmentPopupView: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == applicationPopupPhotos {
            let width = collectionView.frame.width
            let height = collectionView.frame.height
            return CGSize(width: width, height: height)
        }
        return CGSize(width: 0, height: 0)
    }
}

// MARK: - UICollectionViewDelegate

extension ApartmentPopupView: UICollectionViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == applicationPopupPhotos {
            let pageNumber = Int((applicationPopupPhotos.contentOffset.x / applicationPopupPhotos.frame.width).rounded(.toNearestOrAwayFromZero))
            applicationPhotoDots.currentPage = pageNumber
            applicationPopupPageNumber.text = "\(pageNumber + 1) of \(applicationPhotosUrls.count)"
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {}
}
