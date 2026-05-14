import UIKit

final class ApplicationApartmentPhotoCell: UICollectionViewCell {

    let apartmentPhoto = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        installPhotoView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        installPhotoView()
    }

    private func installPhotoView() {
        guard apartmentPhoto.superview == nil else { return }
        apartmentPhoto.translatesAutoresizingMaskIntoConstraints = false
        apartmentPhoto.contentMode = .scaleAspectFill
        apartmentPhoto.clipsToBounds = true
        contentView.addSubview(apartmentPhoto)
        NSLayoutConstraint.activate([
            apartmentPhoto.topAnchor.constraint(equalTo: contentView.topAnchor),
            apartmentPhoto.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            apartmentPhoto.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            apartmentPhoto.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        apartmentPhoto.image = nil
    }
}
