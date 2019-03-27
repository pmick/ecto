//
//  ListCollectionContext+Dequeue.swift
//  Ecto
//
//  Created by Patrick Mick on 3/27/19.
//

import Foundation
import IGListKit

extension ListCollectionContext {
    func dequeueCellFromNib<T>(_ type: T.Type,
                               bundle: Bundle? = nil,
                               for listSectionController: ListSectionController,
                               at index: Int) -> T {
        return dequeueReusableCell(withNibName: String(describing: T.self),
                                   // swiftlint:disable:next force_cast
            bundle: bundle, for: listSectionController, at: index) as! T
    }
}
