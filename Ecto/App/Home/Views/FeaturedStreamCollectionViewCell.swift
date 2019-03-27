//
//  FeaturedStreamCollectionViewCell.swift
//  Twitch
//
//  Created by Patrick Mick on 5/21/18.
//  Copyright © 2018 Patrick Mick. All rights reserved.
//

import UIKit
import IGListKit
import Kingfisher

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

extension FeaturedStreamCollectionViewCell: ListBindable {
    func bindViewModel(_ viewModel: Any) {
        assert(viewModel is StreamViewModel, "Expected \(viewModel) to be of type StreamViewModel")
        guard let viewModel = viewModel as? StreamViewModel else { return }

        titleLabel.text = viewModel.title
        let processor = RoundCornerImageProcessor(cornerRadius: 16, backgroundColor: .clear) >> ResizingImageProcessor(referenceSize: bounds.size, mode: .aspectFill)
        imageView.kf.setImage(with: viewModel.imageUrl, placeholder: nil, options: [.processor(processor), .cacheSerializer(FormatIndicatedCacheSerializer.png), .transition(.fade(0.2))])
    }
}
