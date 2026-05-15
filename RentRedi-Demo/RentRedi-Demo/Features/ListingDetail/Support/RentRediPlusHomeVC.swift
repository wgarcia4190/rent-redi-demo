import UIKit

final class RentRediPlusHomeVC: UIViewController {

    private let viewModel = RentRediPlusHomeViewModel()

    private(set) var applicationPopup: ApartmentPopupView!

    var tenantCardSubmission: TenantCardSubmission? { viewModel.tenantCardSubmission }

    var hasExistingInviteApplication = false

    private let maintenanceDemoButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        installApplicationPopup()
        installMaintenanceDemoButton()
        loadInitialSubmission()
    }

    @objc private func maintenanceDemoTapped() {
        hideApplicationPopup()
        let viewController = MaintenanceRequestDetailVC()
        viewController.modalPresentationStyle = .fullScreen
        viewController.delegate = self
        present(viewController, animated: true)
    }

    // MARK: - Tenant to-do (demo stubs)

    func hideTenantToDoAlert() {}

    func setupTenantToDoAlert() {}

    func updateToDoAlert(title: String, description: String, type: TenantToDoAlertKind) {
        _ = (title, description, type)
    }

    func applyPrequalifyVerb(noun: String) -> String {
        noun
    }
}

// MARK: - ApartmentPopupViewDelegate

extension RentRediPlusHomeVC: ApartmentPopupViewDelegate {

    func hideApplicationPopup() {
        applicationPopup.isHidden = true
    }

    func showApplicationPopup() {
        applicationPopup.isHidden = false
    }

    func presentApplyHome(for submission: TenantCardSubmission) {
        let viewController = mainStoryboard.instantiateViewController(
            withIdentifier: ListingDetailConstants.Storyboard.applyHome
        ) as! ApplyHomeVC
        viewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        viewController.tenantCardSubmission = submission
        viewController.delegate = self
        present(viewController, animated: true)
    }

    func presentPrequalifyHome(for submission: TenantCardSubmission) {
        let viewController = mainStoryboard.instantiateViewController(
            withIdentifier: ListingDetailConstants.Storyboard.prequalifyHome
        ) as! PrequalifyHomeVC
        viewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        viewController.tenantCardSubmission = submission
        present(viewController, animated: true)
    }
}

// MARK: - ApplyHomeVCDelegate

extension RentRediPlusHomeVC: ApplyHomeVCDelegate {

    func applyHomeDidDismiss() {
        showApplicationPopup()
    }
}

// MARK: - MaintenanceRequestDetailVCDelegate

extension RentRediPlusHomeVC: MaintenanceRequestDetailVCDelegate {

    func maintenanceRequestDetailDidDismiss() {
        showApplicationPopup()
    }
}

// MARK: - Setup

private extension RentRediPlusHomeVC {

    var mainStoryboard: UIStoryboard {
        UIStoryboard(name: ListingDetailConstants.Storyboard.main, bundle: nil)
    }

    func installMaintenanceDemoButton() {
        maintenanceDemoButton.translatesAutoresizingMaskIntoConstraints = false
        var config = UIButton.Configuration.filled()
        config.title = ListingDetailConstants.DemoEntry.maintenanceRequestButtonTitle
        config.image = UIImage(systemName: "wrench.and.screwdriver")
        config.imagePadding = 6
        config.cornerStyle = .medium
        config.baseBackgroundColor = .systemIndigo
        maintenanceDemoButton.configuration = config
        maintenanceDemoButton.addTarget(self, action: #selector(maintenanceDemoTapped), for: .touchUpInside)

        view.addSubview(maintenanceDemoButton)
        view.bringSubviewToFront(maintenanceDemoButton)
        NSLayoutConstraint.activate([
            maintenanceDemoButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            maintenanceDemoButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
        ])
    }

    func installApplicationPopup() {
        let popupViewModel = ApartmentPopupViewModel(
            databaseReference: viewModel.databaseReference,
            inviteStatusWriter: viewModel
        )
        let popup = ApartmentPopupView(
            frame: .zero,
            viewModel: popupViewModel
        )
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
    }

    func loadInitialSubmission() {
        viewModel.loadFirstTenantCardSubmission { [weak self] submission in
            guard let self else { return }
            applicationPopup.tenantCardSubmission = submission
            applicationPopup.updateViews()
            if let unit = submission?.listingUnit {
                applicationPopup.fetchListingDetails(for: unit)
            }
        }
    }
}
