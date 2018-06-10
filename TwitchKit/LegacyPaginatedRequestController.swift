//
//  LegacyPaginatedRequestController.swift
//  TwitchKit
//
//  Created by Patrick Mick on 5/28/18.
//  Copyright © 2018 Patrick Mick. All rights reserved.
//

import Foundation

public final class LegacyPaginatedRequestController<T> where T: Resource & LegacyPaginated {
    let resource: T
    private var nextResource: T?
    private var isLoadingMore = false
    private var offset: Int = 0
    public private(set) var hasMorePages = true
    
    public init(resource: T) {
        self.resource = resource
    }
    
    public func loadData(completion: @escaping (Result<T.PayloadType>) -> Void) {
        Twitch().request(resource) { result in
            if case .success(let payload) = result {
                self.hasMorePages = payload.hasMorePages
                self.offset += Twitch.Constants.legacyPageSize
                self.nextResource = self.resource.copy(with: self.offset)
            }
            completion(result)
        }
    }
    
    public func loadMoreData(completion: @escaping (Result<T.PayloadType>) -> Void) {
        guard let nextResource = nextResource, !isLoadingMore, hasMorePages else { return }
        isLoadingMore = true
        return
        Twitch().request(nextResource) { result in
            if case .success(let payload) = result {
                self.hasMorePages = payload.hasMorePages
                self.offset += Twitch.Constants.legacyPageSize
                self.nextResource = self.resource.copy(with: self.offset)
            }
            completion(result)
            self.isLoadingMore = false
        }
    }
}
