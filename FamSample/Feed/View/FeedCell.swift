//
//  FeedCell.swift
//  FamSample
//
//  Created by Aedan Joyce on 12/1/21.
//

import UIKit


// Mark: Cell for feed collection view
class FeedCell: UICollectionViewCell {
    
    let imageView: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = false
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 10
        return imageView
    }()
    
    weak var photo: Photo? {
        didSet {
            guard let photo = photo else {return}
            self.imageView.image = photo.image
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .darkGray
        layer.cornerRadius = 10
        addSubview(imageView)
        imageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, centerX: nil, centerY: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}
