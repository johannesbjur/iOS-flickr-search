//
//  ImageSearchViewController.swift
//  iOS-flickr-search
//
//  Created by Johannes Bjurströmer on 2022-08-21.
//

import UIKit

protocol ImageSearchViewControllerProtocol: AnyObject {
    func addImageDataToCollectionView(imageData: Data, imageId: String)
    func showError(with message: String)
}

final class ImageSearchViewController: UIViewController {
    private var images: [(image: UIImage, id: String)] = []
    private let searchBar = UISearchBar()
    private let imageCollectionView = UICollectionView(frame: .zero,
                                                       collectionViewLayout: UICollectionViewFlowLayout())
    
    private var presenter: ImageSearchPresenterProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = ImageSearchPresenter(imageDownloadService: ImageDownloadService(),
                              viewDelegate: self)
        setupCollectionView()
        setupSearchBar()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageCollectionView.frame = view.bounds
    }
}

// MARK: - ImageSearchViewControllerProtocol functions
extension ImageSearchViewController: ImageSearchViewControllerProtocol {
    func addImageDataToCollectionView(imageData: Data, imageId: String) {
        guard let image = UIImage(data: imageData) else { return }
        images.append((image, imageId))
        DispatchQueue.main.async {
            self.imageCollectionView.reloadData()
        }
    }

    func showError(with message: String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Close", style: .default))
        self.present(alert, animated: true, completion: nil)
    }
}


// MARK: - Private functions
private extension ImageSearchViewController {
    func setupCollectionView() {
        imageCollectionView.register(ImageCollectionViewCell.self,
                                     forCellWithReuseIdentifier: ImageCollectionViewCell.identifier)
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
        view.addSubview(imageCollectionView)
    }

    func setupSearchBar() {
        searchBar.delegate = self
        searchBar.sizeToFit()
        searchBar.showsCancelButton = true
        navigationItem.titleView = searchBar
    }
}

// MARK: - Collection view functions
extension ImageSearchViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = imageCollectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.identifier,
                                                           for: indexPath)
        guard let cell = cell as? ImageCollectionViewCell else { return cell }
        cell.configure(with: images[indexPath.row].image)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard images.indices.contains(indexPath.row) else { return }
        let imageInfoVC = ImageInfoViewController(image: images[indexPath.row].image, imageId: images[indexPath.row].id)
        navigationController?.present(imageInfoVC, animated: true)
    }
}

// MARK: - Collection view layout functions
extension ImageSearchViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 96,
                      height: 96)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 24, left: 24, bottom: 0, right: 24)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 24
    }
}

// MARK: - Search bar delegate functions
extension ImageSearchViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else { return }
        images = []
        imageCollectionView.reloadData()
        Task {
            await self.presenter?.fetchImages(with: searchText)
        }
    }
}
