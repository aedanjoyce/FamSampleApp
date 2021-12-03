//
//  Sticker.swift
//  FamSample
//
//  Created by Aedan Joyce on 12/1/21.
//

import UIKit

//MARK: Sticker class that handles a moveable/pinchable image around the screen
class Sticker: UIView {
    
    weak var view: UIView?
    weak var trashImageView: UIView?
    lazy var imageView: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
        imageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, centerX: nil, centerY: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
    }
    private var size = 50
    convenience init(stickerImage: UIImage, parentView: UIView, trashImageFrame: UIView) {
        self.init()
        imageView.image = stickerImage
        view = parentView
        trashImageView = trashImageFrame
        frame = CGRect(x: 100, y: 300, width: size, height: size)
        self.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handler)))
        self.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(handlePinch)))
    }
    
    // handles the movement of the uiview
    @objc func handler(gesture: UIPanGestureRecognizer){
        let location = gesture.location(in: self.view)
        let draggedView = gesture.view
        draggedView?.center = location
        var isWithinBounds = false
        
        // detect if image is over the trash bin icon
        if let x = trashImageView?.frame.origin.x, let y = trashImageView?.frame.origin.y {
            if location.x <= x + 40 && location.x >= x - 10 &&  location.y <= y + 40 && location.y >= y - 10{
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut) {
                    self.imageView.layer.opacity = 0.5
                    self.trashImageView?.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                } completion: { result in
                    
                }
                isWithinBounds = true
            } else {
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut) {
                    self.imageView.layer.opacity = 1
                    self.trashImageView?.transform = CGAffineTransform(scaleX: 1, y: 1)
                } completion: { result in
                    
                }
                isWithinBounds = false
            }
        }
        
        // if the gesture is released over the trashcan, delete the image.
        if gesture.state == .ended && isWithinBounds {
            print("delete image")
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut) {
                self.imageView.layer.opacity = 1
                self.trashImageView?.transform = CGAffineTransform(scaleX: 1, y: 1)
            } completion: { result in
            }
            self.removeFromSuperview()
        }
    }
    
    // handles pinch gesture
    @objc func handlePinch(gesture: UIPinchGestureRecognizer) {
        let draggedView = gesture.view
        if gesture.state == .changed {
            draggedView?.frame = CGRect(x: gesture.location(in: self.view).x, y: gesture.location(in: self.view).y, width: CGFloat(size) * gesture.scale, height: CGFloat(size) * gesture.scale)
            draggedView?.center = gesture.location(in: self.view)
        }
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    
}
