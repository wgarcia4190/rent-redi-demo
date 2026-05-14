import UIKit
import FirebaseDatabase

class RentRediPlusHomeVC: UIViewController {

    let ref = Database.database().reference()

    var applicationPopup: ApartmentPopupView!
    var tenantCardSubmission: TenantCardSubmission?
    var hasExistingInviteApplication = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        let popup = ApartmentPopupView(frame: .zero)
        popup.translatesAutoresizingMaskIntoConstraints = false
        popup.delegate = self
        popup.tenantCardSubmission = tenantCardSubmission
        view.addSubview(popup)
        NSLayoutConstraint.activate([
            popup.topAnchor.constraint(equalTo: view.topAnchor),
            popup.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            popup.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            popup.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        applicationPopup = popup
        popup.updateViews()
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
