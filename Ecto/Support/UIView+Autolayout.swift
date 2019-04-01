//
//  UIView+Autolayout.swift
//  Twitch
//
//  Created by Patrick Mick on 5/27/18.
//  Copyright © 2018 Patrick Mick. All rights reserved.
//

import UIKit

extension UIView {
    func constrainFillingSuperview(margins: UIEdgeInsets = .zero) {
        assert(superview != nil, "Attempting to constrain view to fill superview, but superview is nil.")
        let view = superview!
        translatesAutoresizingMaskIntoConstraints = false
        leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margins.left).isActive = true
        topAnchor.constraint(equalTo: view.topAnchor, constant: margins.top).isActive = true
        view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: margins.right).isActive = true
        view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: margins.bottom).isActive = true
    }
    
    func constrainFillingSuperviewSafeArea() {
        assert(superview != nil, "Attempting to constrain view to fill superview, but superview is nil.")
        let view = superview!
        translatesAutoresizingMaskIntoConstraints = false
        leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    func constrainCenteringInSuperview() {
        assert(superview != nil, "Attempting to constrain view to fill superview, but superview is nil.")
        let view = superview!
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}
