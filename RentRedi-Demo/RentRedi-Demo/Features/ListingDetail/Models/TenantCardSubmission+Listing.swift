import Foundation

extension TenantCardSubmission {

    struct ListingUnitReference {
        let ownerID: String
        let propertyID: String
        let unitID: String
    }

    var listingUnit: ListingUnitReference? {
        guard let ownerID, let propertyID, let unitID else { return nil }
        return ListingUnitReference(ownerID: ownerID, propertyID: propertyID, unitID: unitID)
    }
}
