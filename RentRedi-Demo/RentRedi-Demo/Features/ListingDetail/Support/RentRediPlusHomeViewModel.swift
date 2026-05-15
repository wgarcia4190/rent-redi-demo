import Foundation
import FirebaseDatabase

final class RentRediPlusHomeViewModel {

    let databaseReference: DatabaseReference

    private let demoRenterProfileUserID: String

    private(set) var tenantCardSubmission: TenantCardSubmission?

    init(
        databaseReference: DatabaseReference = Database.database().reference(),
        demoRenterProfileUserID: String = "rentredi_demo_renter"
    ) {
        self.databaseReference = databaseReference
        self.demoRenterProfileUserID = demoRenterProfileUserID
    }

    func loadFirstTenantCardSubmission(completion: @escaping (TenantCardSubmission?) -> Void) {
        renterTenantCardSubmissionsRef.observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self else { return }

            let child = self.firstSubmissionSnapshot(under: snapshot)
            let submission = child.flatMap { TenantCardSubmission(snapshot: $0) }
            self.tenantCardSubmission = submission

            DispatchQueue.main.async {
                completion(submission)
            }
        }
    }

    private var renterTenantCardSubmissionsRef: DatabaseReference {
        databaseReference
            .child("allUsers")
            .child("renterProfiles")
            .child(demoRenterProfileUserID)
            .child("tenantCardSubmissions")
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
}
