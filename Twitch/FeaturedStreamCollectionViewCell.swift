//
//  FeaturedStreamCollectionViewCell.swift
//  Twitch
//
//  Created by Patrick Mick on 5/21/18.
//  Copyright © 2018 Patrick Mick. All rights reserved.
//

import UIKit

final class FeaturedStreamCollectionViewCell: UICollectionViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageView.adjustsImageWhenAncestorFocused = true
        imageView.layer.cornerRadius = 8
        
        titleLabel.layer.shadowColor = UIColor.black.cgColor
        titleLabel.layer.shadowRadius = 1.5
        titleLabel.layer.shadowOpacity = 0.7
        titleLabel.layer.shadowOffset = .zero
    }
}
