import Foundation

protocol InviteStatusWriting: AnyObject {
    func markInviteAccepted(submission: TenantCardSubmission)
    func markInviteViewed(submission: TenantCardSubmission)
}
