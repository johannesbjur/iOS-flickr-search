//
//  ImageInfoViewController.swift
//  iOS-flickr-search
//
//  Created by Johannes Bjurströmer on 2022-08-22.
//

import Foundation
import UIKit

protocol ImageInfoViewControllerProtocol: AnyObject {
    func setTitleLabel(text: String)
    func setDescriptionLabel(text: String)
}

final class ImageInfoViewController: UIViewController {
    private let imageView = UIImageView(frame: CGRect(x: 0, y: 0,
                                                      width: UIScreen.main.bounds.width,
                                                      height: UIScreen.main.bounds.width))
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    private var presenter: ImageInfoPresenterProtocol?
    
    private let image: UIImage
    private let imageId: String
    
    init(image: UIImage, imageId: String) {
        self.image = image
        self.imageId = imageId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = ImageInfoPresenter(imageDownloadService: ImageDownloadService(), viewDelegate: self, imageId: imageId)
        setupViews()
        setupConstraints()

        Task {
            await presenter?.viewDidLoad()
        }
    }
}

// MARK: - Private functions
private extension ImageInfoViewController {
    func setupViews() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        descriptionLabel.textAlignment = .center
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.numberOfLines = 0

        imageView.image = image
        view.backgroundColor = .white

        view.addSubview(imageView)
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
    }

    func setupConstraints() {
        var constraints = [NSLayoutConstraint]()
        
        constraints.append(titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16))
        constraints.append(titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor))
        constraints.append(titleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor))
        
        constraints.append(descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16))
        constraints.append(descriptionLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor))
        constraints.append(descriptionLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor))
        
        NSLayoutConstraint.activate(constraints)
    }
}

// MARK: - Protocol functions
extension ImageInfoViewController: ImageInfoViewControllerProtocol {
    func setTitleLabel(text: String) {
        DispatchQueue.main.async {
            self.titleLabel.text = text
        }
    }
    
    func setDescriptionLabel(text: String) {
        DispatchQueue.main.async {
            self.descriptionLabel.text = text
        }
    }
    
    
}
