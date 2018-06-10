//
//  SpinnerCell.swift
//  Twitch
//
//  Created by Patrick Mick on 6/2/18.
//  Copyright © 2018 Patrick Mick. All rights reserved.
//

import UIKit

final class SpinnerCell: UICollectionViewCell {
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        activityIndicator.startAnimating()
        contentView.addSubview(activityIndicator)
        activityIndicator.constrainCenteringInSuperview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
