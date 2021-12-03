//
//  Utilities.swift
//  FamSample
//
//  Created by Aedan Joyce on 12/1/21.
//

import UIKit

extension UIView {

//MARK: Anchoring function to simplify auto layout process
func anchor(top: NSLayoutYAxisAnchor?,left: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, right: NSLayoutXAxisAnchor?, centerX: NSLayoutXAxisAnchor?, centerY: NSLayoutYAxisAnchor?, paddingTop: CGFloat, paddingLeft: CGFloat, paddingBottom: CGFloat, paddingRight: CGFloat, width: CGFloat, height: CGFloat) {
    translatesAutoresizingMaskIntoConstraints = false
    if let top = top {
        self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
    }
    if let left = left {
        self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
    }
    if let bottom = bottom {
        bottomAnchor.constraint(equalTo: bottom, constant: paddingBottom).isActive = true
    }
    if let right = right {
        rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
    }
    if let centerX = centerX {
        centerXAnchor.constraint(equalTo: centerX).isActive = true
    }
    if let centerY = centerY {
        centerYAnchor.constraint(equalTo: centerY).isActive = true
    }
    
    if width != 0 {
        widthAnchor.constraint(equalToConstant: width).isActive = true
    }
    if height != 0 {
        heightAnchor.constraint(equalToConstant: height).isActive = true
    }
}
    
}
