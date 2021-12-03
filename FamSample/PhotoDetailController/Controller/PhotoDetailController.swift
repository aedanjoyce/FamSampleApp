//
//  PhotoDetailController.swift
//  FamSample
//
//  Created by Aedan Joyce on 12/1/21.
//

import UIKit

class PhotoDetailController: UIViewController {
    
    weak var photo: Photo? {
        didSet {
            guard let photo = photo else {return}
            imageView.image = photo.image
        }
    }
    
    private var stickerTypes = ["😈","😎","👄","😱","💀","👹","🐫"]
    
    lazy var stickerCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.isPagingEnabled = true
        cv.delegate = self
        cv.dataSource = self
        cv.register(StickerCollectionViewCell.self, forCellWithReuseIdentifier: "cellId")
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        return cv
    }()
    
    
    lazy var dismissButton: UIButton = {
       let button = UIButton()
        button.setImage(UIImage(named: "dismiss"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        return button
    }()
    
    let saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("Save", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        button.layer.cornerRadius = 10
        button.isEnabled = false
        button.addTarget(self, action: #selector(saveModifiedImage), for: .touchUpInside)
        return button
    }()
    
    lazy var trashImage: UIImageView = {
       let imageView = UIImageView(image: UIImage(named: "trash"))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    lazy var imageView: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkGray
        setupViews()
    }
    
    // sets up layout using custom anchoring function I created
    @objc func setupViews() {
        view.backgroundColor = .black
        view.addSubview(dismissButton)
        dismissButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, centerX: nil, centerY: nil, paddingTop: 16, paddingLeft: 16, paddingBottom: 0, paddingRight: 0, width: 35, height: 35)
        view.addSubview(stickerCollectionView)
        stickerCollectionView.anchor(top: nil, left: dismissButton.rightAnchor, bottom: nil, right: view.rightAnchor, centerX: nil, centerY: dismissButton.centerYAnchor, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 0, height: 45)
        view.addSubview(saveButton)
        saveButton.anchor(top: nil, left: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, centerX: nil, centerY: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: -16, paddingRight: 16, width: 70, height: 35)
        view.addSubview(trashImage)
        trashImage.anchor(top: nil, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: nil, centerX: nil, centerY: nil, paddingTop: 0, paddingLeft: 16, paddingBottom: -16, paddingRight: 0, width: 35, height: 35)
        view.addSubview(imageView)
        imageView.anchor(top: dismissButton.bottomAnchor, left: view.leftAnchor, bottom: saveButton.topAnchor, right: view.rightAnchor, centerX: nil, centerY: nil, paddingTop: 12, paddingLeft: 0, paddingBottom: -12, paddingRight: 0, width: 0, height: 0)
        imageView.layer.cornerRadius = 10
    }
    
    @objc private func handleDismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func addSticker(imageType: String) {
        let stickerView = Sticker(stickerImage: UIImage(named: imageType) ?? UIImage(), parentView: self.view, trashImageFrame: trashImage)
        view.addSubview(stickerView)
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @objc func saveModifiedImage() {
        //Create the UIImage by hiding all other elements except the image and sticker
        UIGraphicsBeginImageContext(view.frame.size)
        imageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        saveButton.alpha = 0
        trashImage.alpha = 0
        dismissButton.alpha = 0
        stickerCollectionView.alpha = 0
        imageView.layer.cornerRadius = 0
        
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return }
        UIGraphicsEndImageContext()

        //Save it to the camera roll
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        
        
        
        // save to disk
        let modifiedPhoto = ModifiedPhoto(context: context)
        modifiedPhoto.image = image.pngData()
            
        do {
            try context.save()
            print("saved image")
        } catch {
            print("error saving image")
        }
        
        self.dismiss(animated: true, completion: nil)
    }

    
    
    
}

//MARK: Setup for sticker collection view

extension PhotoDetailController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stickerTypes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! StickerCollectionViewCell
        cell.imageView.image = UIImage(named: self.stickerTypes[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.height, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.addSticker(imageType: self.stickerTypes[indexPath.item])
            self.saveButton.isEnabled = true
            self.saveButton.backgroundColor = .white
        }
    }
}

//MARK: Cell for sticker collection view within photo detail view
class StickerCollectionViewCell: UICollectionViewCell {
    
    lazy var imageView: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        addSubview(imageView)
        imageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, centerX: nil, centerY: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
