//
//  Either.swift
//  Twitch
//
//  Created by Patrick Mick on 10/21/18.
//  Copyright © 2018 Patrick Mick. All rights reserved.
//

import Foundation

enum Either<A, B> {
    case lhs(A)
    case rhs(B)
}
