//
//  SpinnerCell.swift
//  Twitch
//
//  Created by Patrick Mick on 6/2/18.
//  Copyright © 2018 Patrick Mick. All rights reserved.
//

import UIKit

final class SpinnerCell: UICollectionViewCell {
    let activityIndicator = UIActivityIndicatorView(style: .white)

    override init(frame: CGRect) {
        super.init(frame: frame)

        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = false
        contentView.addSubview(activityIndicator)
        activityIndicator.constrainCenteringInSuperview()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        activityIndicator.startAnimating()
    }
}
