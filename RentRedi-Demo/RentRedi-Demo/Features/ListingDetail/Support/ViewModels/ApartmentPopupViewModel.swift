import Foundation
import FirebaseDatabase
import SwiftyJSON

struct ApartmentPopupInviteDisplay {
    let titleText: String
    let streetAddressText: String
    let regionLineText: String
    let startButtonTitle: String
    let tenantToDoTitle: String
    let tenantToDoDescription: String
}

final class ApartmentPopupViewModel {

    enum ApplicationFlow {
        case application
        case prequalification
    }

    private let databaseReference: DatabaseReference
    private let databaseFunctions: DatabaseFunctions
    private weak var inviteStatusWriter: InviteStatusWriting?

    init(
        databaseReference: DatabaseReference = Database.database().reference(),
        databaseFunctions: DatabaseFunctions = DatabaseFunctions(),
        inviteStatusWriter: InviteStatusWriting? = nil
    ) {
        self.databaseReference = databaseReference
        self.databaseFunctions = databaseFunctions
        self.inviteStatusWriter = inviteStatusWriter
    }

    // MARK: - Invite

    func markInviteAccepted(submission: TenantCardSubmission) {
        inviteStatusWriter?.markInviteAccepted(submission: submission)
    }

    func markInviteViewed(submission: TenantCardSubmission) {
        inviteStatusWriter?.markInviteViewed(submission: submission)
    }

    func applicationFlow(for submission: TenantCardSubmission) -> ApplicationFlow? {
        guard FirebaseDatabaseConstants.InviteTenantKey.childKey(for: submission) != nil else { return nil }
        switch submission.submissionType {
        case ListingDetailConstants.SubmissionType.application:
            return .application
        case ListingDetailConstants.SubmissionType.prequalification:
            return .prequalification
        default:
            databaseFunctions.log(message: "Error: No submission type found")
            return nil
        }
    }

    func makeInviteDisplay(submission: TenantCardSubmission?, startButtonTitle: String) -> ApartmentPopupInviteDisplay? {
        guard let submission else { return nil }
        let verb = submission.verb.capitalizeFirstLetter()
        return ApartmentPopupInviteDisplay(
            titleText: "Invite to \(verb)",
            streetAddressText: "\(submission.address ?? "Error, Not Available"), Unit \(submission.unitID ?? "")",
            regionLineText: "\(submission.city ?? ""), \(submission.state ?? "") \(submission.zip ?? "")",
            startButtonTitle: startButtonTitle,
            tenantToDoTitle: "You have been invited to \(verb) to \(submission.fullAddress).",
            tenantToDoDescription: "Tap to start, or go to '\(submission.submissionType ?? "")'"
        )
    }

    func defaultInviteStreetLine(submission: TenantCardSubmission?) -> String {
        let verb = submission?.verb.capitalizeFirstLetter() ?? "Apply"
        let address = submission?.fullAddress ?? "an unknown address"
        return "You have been invited to \(verb) to \(address)"
    }

    // MARK: - Listing

    func fetchListingDetails(
        for unit: TenantCardSubmission.ListingUnitReference,
        onBedrooms: @escaping (String) -> Void,
        onBathrooms: @escaping (String) -> Void,
        onMonthlyRent: @escaping (String) -> Void,
        onPhotoURLs: @escaping ([URL]) -> Void,
        onNoPhotos: @escaping () -> Void
    ) {
        let ownerID = unit.ownerID
        let propertyID = unit.propertyID
        let unitID = unit.unitID

        fetchUnitDetail(
            ownerID: ownerID,
            propertyID: propertyID,
            unitID: unitID,
            field: FirebaseDatabaseConstants.Field.numberOfBedrooms,
            completion: onBedrooms
        )
        fetchUnitDetail(
            ownerID: ownerID,
            propertyID: propertyID,
            unitID: unitID,
            field: FirebaseDatabaseConstants.Field.numberOfBathrooms,
            completion: onBathrooms
        )
        fetchUnitDetail(
            ownerID: ownerID,
            propertyID: propertyID,
            unitID: unitID,
            field: FirebaseDatabaseConstants.Field.listingMonthlyRent,
            completion: onMonthlyRent
        )
        loadListingPhotoURLs(
            ownerID: ownerID,
            propertyID: propertyID,
            unitID: unitID,
            onPhotoURLs: onPhotoURLs,
            onNoPhotos: onNoPhotos
        )
    }

    // MARK: - Private

    private func fetchUnitDetail(
        ownerID: String,
        propertyID: String,
        unitID: String,
        field: String,
        completion: @escaping (String) -> Void
    ) {
        let path = FirebaseDatabaseConstants.Path.unitDetail(
            ownerID: ownerID,
            propertyID: propertyID,
            unitID: unitID,
            field: field
        )
        databaseFunctions.readOnceFromFirebaseAndReturnString(pathToValue: path, completion: completion)
    }

    private func loadListingPhotoURLs(
        ownerID: String,
        propertyID: String,
        unitID: String,
        onPhotoURLs: @escaping ([URL]) -> Void,
        onNoPhotos: @escaping () -> Void
    ) {
        let unitPhotosPath = FirebaseDatabaseConstants.Path.unitPhotos(
            ownerID: ownerID,
            propertyID: propertyID,
            unitID: unitID
        )
        let propertyPhotosPath = FirebaseDatabaseConstants.Path.propertyPhotos(
            ownerID: ownerID,
            propertyID: propertyID
        )

        var urls: [URL] = []
        let group = DispatchGroup()

        group.enter()
        databaseFunctions.readOnceFromFirebaseAndReturnJSON(pathToValue: unitPhotosPath) { json in
            urls.append(contentsOf: self.photoURLs(from: json))
            group.leave()
        }

        group.enter()
        databaseFunctions.readOnceFromFirebaseAndReturnJSON(pathToValue: propertyPhotosPath) { json in
            urls.append(contentsOf: self.photoURLs(from: json))
            group.leave()
        }

        group.notify(queue: .main) {
            if urls.isEmpty {
                onNoPhotos()
            } else {
                onPhotoURLs(urls)
            }
        }
    }

    private func photoURLs(from photos: [String: JSON]) -> [URL] {
        let downloadURLKey = FirebaseDatabaseConstants.Field.downloadURL
        return photos.values
            .compactMap { $0[downloadURLKey].stringValue }
            .compactMap(URL.init(string:))
    }
}
