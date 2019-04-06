//
//  UIScrollView+HasReachedEnd.swift
//  Twitch
//
//  Created by Patrick Mick on 5/28/18.
//  Copyright © 2018 Patrick Mick. All rights reserved.
//

import UIKit

extension UIScrollView {
    /// Returns true when the user is scrolling at or past the bottom of the content.
    func hasReachedBottom(withBuffer buffer: CGFloat) -> Bool {
        let offset = contentOffset.y
        return (offset + bounds.height) >= (contentSize.height + contentInset.bottom - buffer)
    }

    func hasReachedTrailingEdge(withBuffer buffer: CGFloat) -> Bool {
        let offset = contentOffset.x
        return (offset + bounds.width) >= (contentSize.width + contentInset.right - buffer)
    }
}
