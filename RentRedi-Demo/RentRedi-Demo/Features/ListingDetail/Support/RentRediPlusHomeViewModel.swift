import Foundation
import FirebaseDatabase

final class RentRediPlusHomeViewModel {

    let databaseReference: DatabaseReference

    private let demoRenterProfileUserID: String

    private(set) var tenantCardSubmission: TenantCardSubmission?

    init(
        databaseReference: DatabaseReference = Database.database().reference(),
        demoRenterProfileUserID: String = ListingDetailConstants.Demo.renterProfileUserID
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
        FirebaseDatabaseConstants.Reference.renterTenantCardSubmissions(
            databaseReference,
            renterID: demoRenterProfileUserID
        )
    }

    func markInviteAccepted(submission: TenantCardSubmission) {
        setInviteStatus(ListingDetailConstants.InviteStatus.accepted, submission: submission)
    }

    func markInviteViewed(submission: TenantCardSubmission) {
        setInviteStatus(ListingDetailConstants.InviteStatus.viewed, submission: submission)
    }

    private func setInviteStatus(_ status: String, submission: TenantCardSubmission) {
        guard let key = FirebaseDatabaseConstants.InviteTenantKey.childKey(for: submission) else { return }
        FirebaseDatabaseConstants.Reference.inviteStatus(databaseReference, inviteKey: key)
            .setValue(status)
    }

    private func firstSubmissionSnapshot(under snapshot: DataSnapshot) -> DataSnapshot? {
        let preferredIndex = FirebaseDatabaseConstants.SubmissionIndex.preferredFirst
        if snapshot.hasChild(preferredIndex) {
            return snapshot.childSnapshot(forPath: preferredIndex)
        }
        var children: [DataSnapshot] = []
        for item in snapshot.children {
            guard let child = item as? DataSnapshot, child.exists() else { continue }
            children.append(child)
        }
        return children.sorted { $0.key < $1.key }.first
    }
}

extension RentRediPlusHomeViewModel: InviteStatusWriting {}
