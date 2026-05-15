import Foundation
import FirebaseDatabase

/// Firebase Realtime Database path segments, field names, and path/reference builders.
enum FirebaseDatabaseConstants {

    enum Segment {
        static let allUsers = "allUsers"
        static let renterProfiles = "renterProfiles"
        static let ownerProfiles = "ownerProfiles"
        static let inviteTenant = "inviteTenant"
        static let tenantCardSubmissions = "tenantCardSubmissions"
        static let profile = "profile"
        static let properties = "properties"
        static let units = "units"
        static let unitDetails = "unitDetails"
        static let propertyDetails = "propertyDetails"
    }

    enum Field {
        static let inviteStatus = "inviteStatus"
        static let downloadURL = "downloadURL"
        static let numberOfBedrooms = "numberOfBedrooms"
        static let numberOfBathrooms = "numberOfBathrooms"
        static let listingMonthlyRent = "listingMonthlyRent"
        static let photos = "photos"
    }

    enum SubmissionIndex {
        static let preferredFirst = "0"
    }

    enum InviteTenantKey {
        static func childKey(
            ownerID: String,
            propertyID: String,
            unitID: String,
            renterID: String,
            submissionType: String
        ) -> String {
            "\(ownerID)\(propertyID)\(unitID)\(renterID)_\(submissionType)"
        }

        static func childKey(for submission: TenantCardSubmission) -> String? {
            guard let submissionType = submission.submissionType,
                  let ownerID = submission.ownerID,
                  let propertyID = submission.propertyID,
                  let unitID = submission.unitID,
                  let renterID = submission.renterID else { return nil }
            return childKey(
                ownerID: ownerID,
                propertyID: propertyID,
                unitID: unitID,
                renterID: renterID,
                submissionType: submissionType
            )
        }
    }

    /// Slash-separated paths for `DatabaseFunctions.readOnceFromFirebase…`.
    enum Path {
        static func renterTenantCardSubmissions(renterID: String) -> String {
            [
                Segment.allUsers,
                Segment.renterProfiles,
                renterID,
                Segment.tenantCardSubmissions,
            ].joined(separator: "/")
        }

        static func unitDetail(ownerID: String, propertyID: String, unitID: String, field: String) -> String {
            [
                Segment.allUsers,
                Segment.ownerProfiles,
                ownerID,
                Segment.profile,
                Segment.properties,
                propertyID,
                Segment.units,
                unitID,
                Segment.unitDetails,
                field,
            ].joined(separator: "/")
        }

        static func unitPhotos(ownerID: String, propertyID: String, unitID: String) -> String {
            unitDetail(ownerID: ownerID, propertyID: propertyID, unitID: unitID, field: Field.photos)
        }

        static func propertyPhotos(ownerID: String, propertyID: String) -> String {
            [
                Segment.allUsers,
                Segment.ownerProfiles,
                ownerID,
                Segment.profile,
                Segment.properties,
                propertyID,
                Segment.propertyDetails,
                Field.photos,
            ].joined(separator: "/")
        }
    }

    /// `DatabaseReference` chains for direct read/write from view models.
    enum Reference {
        static func renterTenantCardSubmissions(
            _ database: DatabaseReference,
            renterID: String
        ) -> DatabaseReference {
            database
                .child(Segment.allUsers)
                .child(Segment.renterProfiles)
                .child(renterID)
                .child(Segment.tenantCardSubmissions)
        }

        static func inviteStatus(
            _ database: DatabaseReference,
            inviteKey: String
        ) -> DatabaseReference {
            database
                .child(Segment.inviteTenant)
                .child(inviteKey)
                .child(Field.inviteStatus)
        }
    }
}
