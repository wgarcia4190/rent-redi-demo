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

    private let databaseReference: DatabaseReference
    private let databaseFunctions: DatabaseFunctions

    init(
        databaseReference: DatabaseReference = Database.database().reference(),
        databaseFunctions: DatabaseFunctions = DatabaseFunctions()
    ) {
        self.databaseReference = databaseReference
        self.databaseFunctions = databaseFunctions
    }

    // MARK: - Invite status

    func updateInviteStatus(_ status: String, submission: TenantCardSubmission) {
        guard let key = inviteTenantChildKey(for: submission) else { return }
        databaseReference.child("inviteTenant").child(key).child("inviteStatus").setValue(status)
    }

    func startApplicationFlow(for submission: TenantCardSubmission) -> StartApplicationFlow? {
        guard inviteTenantChildKey(for: submission) != nil else { return nil }
        switch submission.submissionType {
        case "application":
            return .application
        case "prequalification":
            return .prequalification
        default:
            databaseFunctions.log(message: "Error: No submission type found")
            return nil
        }
    }

    enum StartApplicationFlow {
        case application
        case prequalification
    }

    // MARK: - Invite UI copy

    func makeInviteDisplay(submission: TenantCardSubmission?, startButtonTitle: String) -> ApartmentPopupInviteDisplay? {
        guard let submission else { return nil }
        let verb = submission.verb.capitalizeFirstLetter()
        let titleText = "Invite to \(verb)"
        let streetAddressText = "\(submission.address ?? "Error, Not Available"), Unit \(submission.unitID ?? "")"
        let regionLineText = "\(submission.city ?? ""), \(submission.state ?? "") \(submission.zip ?? "")"
        let todoTitle = "You have been invited to \(verb) to \(submission.fullAddress)."
        let todoDescription = "Tap to start, or go to '\(submission.submissionType ?? "")'"
        return ApartmentPopupInviteDisplay(
            titleText: titleText,
            streetAddressText: streetAddressText,
            regionLineText: regionLineText,
            startButtonTitle: startButtonTitle,
            tenantToDoTitle: todoTitle,
            tenantToDoDescription: todoDescription
        )
    }

    func defaultInviteStreetLine(submission: TenantCardSubmission?) -> String {
        let verb = submission?.verb.capitalizeFirstLetter() ?? "Apply"
        let address = submission?.fullAddress ?? "an unknown address"
        return "You have been invited to \(verb) to \(address)"
    }

    // MARK: - Listing details

    func fetchListingBedrooms(ownerID: String, propertyID: String, unitID: String, completion: @escaping (String) -> Void) {
        let path = Self.unitDetailsPath(ownerID: ownerID, propertyID: propertyID, unitID: unitID, field: "numberOfBedrooms")
        databaseFunctions.readOnceFromFirebaseAndReturnString(pathToValue: path, completion: completion)
    }

    func fetchListingBathrooms(ownerID: String, propertyID: String, unitID: String, completion: @escaping (String) -> Void) {
        let path = Self.unitDetailsPath(ownerID: ownerID, propertyID: propertyID, unitID: unitID, field: "numberOfBathrooms")
        databaseFunctions.readOnceFromFirebaseAndReturnString(pathToValue: path, completion: completion)
    }

    func fetchListingMonthlyRent(ownerID: String, propertyID: String, unitID: String, completion: @escaping (String) -> Void) {
        let path = Self.unitDetailsPath(ownerID: ownerID, propertyID: propertyID, unitID: unitID, field: "listingMonthlyRent")
        databaseFunctions.readOnceFromFirebaseAndReturnString(pathToValue: path, completion: completion)
    }

    /// Loads unit and property photo maps; calls `onUpdate` whenever new URLs are available, then `onDefaultInvite` if both loads finished with no URLs.
    func loadListingPhotoURLs(
        ownerID: String,
        propertyID: String,
        unitID: String,
        onUpdate: @escaping ([URL]) -> Void,
        onDefaultInvite: @escaping () -> Void
    ) {
        let unitPath = Self.unitPhotosPath(ownerID: ownerID, propertyID: propertyID, unitID: unitID)
        let propertyPath = Self.propertyPhotosPath(ownerID: ownerID, propertyID: propertyID)

        var urls: [URL] = []
        var finished = 0

        let handle: ([String: JSON]) -> Void = { json in
            let new = Self.photoURLs(from: json)
            urls.append(contentsOf: new)
            if !urls.isEmpty {
                onUpdate(urls)
            }
            finished += 1
            if finished == 2, urls.isEmpty {
                onDefaultInvite()
            }
        }

        databaseFunctions.readOnceFromFirebaseAndReturnJSON(pathToValue: unitPath, completion: handle)
        databaseFunctions.readOnceFromFirebaseAndReturnJSON(pathToValue: propertyPath, completion: handle)
    }

    // MARK: - Private

    private func inviteTenantChildKey(for submission: TenantCardSubmission) -> String? {
        guard let submissionType = submission.submissionType,
              let ownerID = submission.ownerID,
              let propertyID = submission.propertyID,
              let unitID = submission.unitID,
              let renterID = submission.renterID else { return nil }
        return "\(ownerID)\(propertyID)\(unitID)\(renterID)_\(submissionType)"
    }

    private static func photoURLs(from photos: [String: JSON]) -> [URL] {
        photos.values.compactMap { $0["downloadURL"].stringValue }.compactMap(URL.init(string:))
    }

    private static func unitDetailsPath(ownerID: String, propertyID: String, unitID: String, field: String) -> String {
        "allUsers/ownerProfiles/\(ownerID)/profile/properties/\(propertyID)/units/\(unitID)/unitDetails/\(field)"
    }

    private static func unitPhotosPath(ownerID: String, propertyID: String, unitID: String) -> String {
        unitDetailsPath(ownerID: ownerID, propertyID: propertyID, unitID: unitID, field: "photos")
    }

    private static func propertyPhotosPath(ownerID: String, propertyID: String) -> String {
        "allUsers/ownerProfiles/\(ownerID)/profile/properties/\(propertyID)/propertyDetails/photos"
    }
}
