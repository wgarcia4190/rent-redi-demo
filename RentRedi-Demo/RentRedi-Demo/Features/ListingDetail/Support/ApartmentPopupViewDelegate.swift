import UIKit

protocol ApartmentPopupViewDelegate: AnyObject {
    var tenantCardSubmission: TenantCardSubmission? { get }
    var hasExistingInviteApplication: Bool { get set }
    func hideApplicationPopup()
    func hideTenantToDoAlert()
    func setupTenantToDoAlert()
    func updateToDoAlert(title: String, description: String, type: TenantToDoAlertKind)
    func applyPrequalifyVerb(noun: String) -> String
    func presentApplyHome(for submission: TenantCardSubmission)
    func presentPrequalifyHome(for submission: TenantCardSubmission)
}
