import UIKit
import FirebaseDatabase

class RentRediPlusHomeVC: UIViewController {

    private let viewModel = RentRediPlusHomeViewModel()

    /// Remove after moving logic from ApartmentPopupView to ViewModel
    var ref: DatabaseReference { viewModel.databaseReference }

    var applicationPopup: ApartmentPopupView!

    var tenantCardSubmission: TenantCardSubmission? { viewModel.tenantCardSubmission }

    var hasExistingInviteApplication = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        let popup = ApartmentPopupView(frame: .zero)
        popup.translatesAutoresizingMaskIntoConstraints = false
        popup.delegate = self
        view.addSubview(popup)
        NSLayoutConstraint.activate([
            popup.topAnchor.constraint(equalTo: view.topAnchor),
            popup.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            popup.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            popup.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        applicationPopup = popup

        viewModel.loadFirstTenantCardSubmission { [weak self] submission in
            guard let self else { return }
            self.applicationPopup.tenantCardSubmission = submission
            self.applicationPopup.updateViews()
            if let submission,
               let ownerID = submission.ownerID,
               let propertyID = submission.propertyID,
               let unitID = submission.unitID {
                self.applicationPopup.fetchListingDetails(ownerID: ownerID, propertyID: propertyID, unitID: unitID)
            }
        }
    }

    func hideTenantToDoAlert() {}

    func setupTenantToDoAlert() {}

    func updateToDoAlert(title: String, description: String, type: TenantToDoAlertKind) {
        _ = (title, description, type)
    }

    func applyPrequalifyVerb(noun: String) -> String {
        noun
    }
}
