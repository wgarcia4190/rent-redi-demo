import UIKit
import FirebaseDatabase

class RentRediPlusHomeVC: UIViewController {

    private let demoRenterProfileUserID = "rentredi_demo_renter"

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
        view.addSubview(popup)
        NSLayoutConstraint.activate([
            popup.topAnchor.constraint(equalTo: view.topAnchor),
            popup.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            popup.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            popup.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        applicationPopup = popup

        loadFirstTenantCardSubmission()
    }

    private func renterTenantCardSubmissionsRef(uid: String) -> DatabaseReference {
        ref.child("allUsers").child("renterProfiles").child(uid).child("tenantCardSubmissions")
    }

    private func loadFirstTenantCardSubmission() {
        let uid = demoRenterProfileUserID

        renterTenantCardSubmissionsRef(uid: uid).observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self else { return }

            let child = self.firstSubmissionSnapshot(under: snapshot)
            let submission = child.flatMap { TenantCardSubmission(snapshot: $0) }

            DispatchQueue.main.async {
                self.tenantCardSubmission = submission
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
    }

    private func firstSubmissionSnapshot(under snapshot: DataSnapshot) -> DataSnapshot? {
        if snapshot.hasChild("0") {
            return snapshot.childSnapshot(forPath: "0")
        }
        var children: [DataSnapshot] = []
        for item in snapshot.children {
            guard let child = item as? DataSnapshot, child.exists() else { continue }
            children.append(child)
        }
        return children.sorted { $0.key < $1.key }.first
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
