import Foundation

/// Demo maintenance request content for `MaintenanceRequestDetailVC`.
enum MaintenanceRequestSample {
    static let requestID = "MR-2026-0142"
    static let status = "In progress"
    static let submittedDate = "May 10, 2026"
    static let category = "Plumbing"
    static let issueDescription = """
    Kitchen sink is draining slowly and there is a small leak under the cabinet. \
    Photos attached from the initial inspection.
    """
    static let photoURLs = CarouselSampleImages.urls
}
