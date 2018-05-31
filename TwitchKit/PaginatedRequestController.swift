//
//  PaginatedRequestController.swift
//  TwitchKit
//
//  Created by Patrick Mick on 5/28/18.
//  Copyright © 2018 Patrick Mick. All rights reserved.
//

import Foundation

public final class PaginatedRequestController<T> where T: Resource & Paginated {
    let resource: T
    private var nextResource: T?
    private var isLoadingMore = false
    private var hasMorePages = true
    
    public init(resource: T) {
        self.resource = resource
    }
    
    public func loadData(completion: @escaping (Result<T.PayloadType>) -> Void) {
        Twitch().request(resource) { result in
            if case .success(let payload) = result {
                self.hasMorePages = payload.hasMorePages
                self.nextResource = payload.cursor.map(self.resource.copy)
            }
            completion(result)
        }
    }
    
    public func loadMoreData(completion: @escaping (Result<T.PayloadType>) -> Void) {
        guard let nextResource = nextResource, !isLoadingMore, hasMorePages else { return }
        isLoadingMore = true
        Twitch().request(nextResource) { result in
            if case .success(let payload) = result {
//                self.hasMorePages = payload.hasMorePages
                self.nextResource = payload.cursor.map(self.resource.copy)
            }
            completion(result)
            self.isLoadingMore = false
        }
    }
}
