//
//  LazyLoadHelper.swift
//  ShelfPlayer
//
//  Created by Rasmus Krämer on 13.09.24.
//

import Foundation
import SwiftUI
import Defaults
import ShelfPlayerKit

@Observable
internal final class LazyLoadHelper<T: Item, O: Sendable>: Sendable {
    private static var PAGE_SIZE: Int { 100 }
    
    @MainActor private(set) internal var items: [T]
    @MainActor private(set) internal var count: Int
    
    @MainActor internal var sortOrder: O
    @MainActor internal var ascending: Bool
    
    @MainActor private(set) internal var failed: Bool
    @MainActor private(set) internal var working: Bool
    @MainActor private(set) internal var finished: Bool
    
    @MainActor internal var library: Library!
    
    private let loadMore: @Sendable (_ page: Int, _ sortOrder: O, _ ascending: Bool, _ library: Library) async throws -> ([T], Int)
    
    @MainActor
    init(sortOrder: O, ascending: Bool, loadMore: @Sendable @escaping (_ page: Int, _ sortOrder: O, _ ascending: Bool, _ library: Library) async throws -> ([T], Int)) {
        self.sortOrder = sortOrder
        self.ascending = ascending
        
        items = []
        count = 0
        
        failed = false
        working = false
        finished = false
        
        self.loadMore = loadMore
    }
    
    func initialLoad() {
        didReachEndOfLoadedContent()
    }
    func refresh() async {
        await MainActor.withAnimation { [self] in
            items = []
            count = 0
            
            failed = false
            working = true
            finished = false
        }
        
        didReachEndOfLoadedContent(bypassWorking: true)
    }
    
    func didReachEndOfLoadedContent(bypassWorking: Bool = false) {
        Task {
            guard await !working || bypassWorking, await !finished else {
                return
            }
            
            await MainActor.withAnimation { [self] in
                failed = false
                working = true
            }
            
            let itemCount = await items.count
            
            guard itemCount % Self.PAGE_SIZE == 0 else {
                await MainActor.withAnimation { [self] in
                    finished = true
                }
                
                return
            }
            
            let page = itemCount / Self.PAGE_SIZE
            
            do {
                let (received, totalCount) = try await loadMore(page, sortOrder, ascending, library)
                
                await MainActor.withAnimation { [self] in
                    items += received
                    count = totalCount
                    
                    working = false
                }
            } catch {
                await MainActor.withAnimation { [self] in
                    failed = true
                }
            }
        }
    }
}

internal extension LazyLoadHelper {
    @MainActor
    static var audiobooks: LazyLoadHelper<Audiobook, AudiobookSortOrder> {
        .init(sortOrder: Defaults[.audiobooksSortOrder], ascending: Defaults[.audiobooksAscending], loadMore: { _, _, _, _ in
            // try await AudiobookshelfClient.shared.audiobooks(libraryID: $3, sortOrder: $1, ascending: $2, limit: PAGE_SIZE, page: $0)
            ([], 0)
        })
    }
    
    @MainActor
    static func audiobooks(seriesID: String) -> LazyLoadHelper<Audiobook, ()?> {
        .init(sortOrder: nil, ascending: true, loadMore: { _, _, _, _ in
            /*
            try await AudiobookshelfClient.shared.audiobooks(seriesID: seriesID,
                                                             libraryID: $3,
                                                             sortOrder: $1 == .seriesName ? nil : $1,
                                                             ascending: $2,
                                                             limit: PAGE_SIZE,
                                                             page: $0)
             */
            ([], 0)
        })
    }
    
    @MainActor
    static var series: LazyLoadHelper<Series, SeriesSortOrder> {
        .init(sortOrder: Defaults[.seriesSortOrder], ascending: Defaults[.seriesAscending], loadMore: {
            try await ABSClient[$3.connectionID].series(in: $3.id, sortOrder: $1, ascending: $2, limit: PAGE_SIZE, page: $0)
        })
    }
    
    @MainActor
    static var podcasts: LazyLoadHelper<Podcast, Never?> {
        .init(sortOrder: nil, ascending: Defaults[.podcastsAscending], loadMore: { _, _, _, _ in
            // try await AudiobookshelfClient.shared.podcasts(libraryID: $3, limit: PAGE_SIZE, page: $0)
            ([], 0)
        })
    }
}
