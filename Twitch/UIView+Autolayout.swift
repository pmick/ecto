//
//  UIView+Autolayout.swift
//  Twitch
//
//  Created by Patrick Mick on 5/27/18.
//  Copyright © 2018 Patrick Mick. All rights reserved.
//

import UIKit

extension UIView {
    func constrainFillingSuperview() {
        assert(superview != nil, "Attempting to constrain view to fill superview, but superview is nil.")
        let view = superview!
        translatesAutoresizingMaskIntoConstraints = false
        leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
}
