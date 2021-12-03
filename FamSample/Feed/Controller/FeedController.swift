//
//  ViewController.swift
//  FamSample
//
//  Created by Aedan Joyce on 11/30/21.
//

import UIKit

class FeedController: UICollectionViewController {
    
    var photos = [Photo]()
    var nextPage: Int?
    var isPageable = true
    lazy var refreshControl: UIRefreshControl = {
       let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(fetchPhotos), for: .valueChanged)
        return refreshControl
    }()
    
    

    // sets up custom collection view layout
    init() {
        super.init(collectionViewLayout: FeedController.setupLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let cellId = "cellId"
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.register(FeedCell.self, forCellWithReuseIdentifier: cellId)
        navigationItem.title = "Fam Sample App"
        collectionView.refreshControl = refreshControl
        // Do any additional setup after loading the view.
        fetchPhotos()
    }
    
    // fetch photos
    @objc private func fetchPhotos() {
        self.photos.removeAll()
        self.isPageable = true
        self.nextPage = nil
        FeedService.fetchImages(page: nextPage ?? 1) { photos, nextPage, isPageable  in
            self.photos = photos
            self.isPageable = isPageable
            self.nextPage = nextPage
            DispatchQueue.main.async {
                if self.refreshControl.isRefreshing {
                    self.refreshControl.endRefreshing()
                }
                self.fetchModifiedImagesFromDisk()
                self.collectionView.reloadData()
            }
        }
    }
    
    private var modifiedPhotos = [ModifiedPhoto]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // fetches photos with stickers from disk and transforms them into Photo objects
    func fetchModifiedImagesFromDisk() {
        do {

            
            modifiedPhotos = try context.fetch(ModifiedPhoto.fetchRequest())
            let transformedPhotos = modifiedPhotos.map { photo in
                return Photo(image: UIImage(data: photo.image!) ?? UIImage())
            }
            self.photos.append(contentsOf: transformedPhotos)
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        } catch {
            // error
        }
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! FeedCell
        if self.photos.count > 0 {
            cell.photo = self.photos[indexPath.item]
        }
        return cell
    }
    
    // pagination implementation
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == self.photos.count - 1 && isPageable {
            FeedService.fetchImages(page: nextPage ?? 1) { [unowned self] photos, nextPage,isPageable in
                self.photos.append(contentsOf: photos)
                self.nextPage = nextPage
                self.isPageable = isPageable
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    self.collectionView.layoutIfNeeded()
                }
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let photoDetailController = PhotoDetailController()
        photoDetailController.modalPresentationStyle = .fullScreen
        photoDetailController.photo = self.photos[indexPath.item]
        DispatchQueue.main.async {
            self.present(photoDetailController, animated: true, completion: nil)
        }
    }
    
    
    
    
}

// MARK: Setup Custom Layout
extension FeedController {
    
    
    static func setupLayout() -> UICollectionViewCompositionalLayout {
        
        // top section (2 small, 1 Large) implmentation
        let mainItem = NSCollectionLayoutItem(
          layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(2/3),
            heightDimension: .fractionalHeight(1.0)))

        mainItem.contentInsets = NSDirectionalEdgeInsets(
          top: 2,
          leading: 2,
          bottom: 2,
          trailing: 2)

        // 2
        let pairItem = NSCollectionLayoutItem(
          layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(0.5)))

        pairItem.contentInsets = NSDirectionalEdgeInsets(
          top: 2,
          leading: 2,
          bottom: 2,
          trailing: 2)

        let trailingGroup = NSCollectionLayoutGroup.vertical(
          layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1/3),
            heightDimension: .fractionalHeight(1.0)),
          subitem: pairItem,
          count: 2)

        // 1
        let topSectionGroup = NSCollectionLayoutGroup.horizontal(
          layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(250)),
          subitems: [mainItem, trailingGroup])
        
        
        // middle section
        let middleItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.4), heightDimension: .absolute(125)))
        middleItem.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
        let middleSectionGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(125)), subitem: middleItem, count: 3)
        let middleNestedGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(254)), subitem: middleSectionGroup, count: 2)
        middleNestedGroup.interItemSpacing = NSCollectionLayoutSpacing.fixed(2)
        middleNestedGroup.edgeSpacing = NSCollectionLayoutEdgeSpacing(leading: nil, top: NSCollectionLayoutSpacing.fixed(2), trailing: nil, bottom: NSCollectionLayoutSpacing.fixed(2))
        
        
        // bottom section (1 Large, 2 small)
        let bottomSectionGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(250)), subitems: [trailingGroup, mainItem])
        
        
        let compiledGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(10000)), subitems: [topSectionGroup, middleNestedGroup, bottomSectionGroup])

        let section = NSCollectionLayoutSection(group: compiledGroup)
        section.supplementariesFollowContentInsets = true

        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 1
        config.scrollDirection = .vertical
        let layout = UICollectionViewCompositionalLayout(section: section, configuration: config)
        
        
        return layout
    }
    
    
    
}

