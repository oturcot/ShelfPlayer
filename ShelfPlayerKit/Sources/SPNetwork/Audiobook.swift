//
//  AudiobookshelfClient+Audiobooks.swift
//  Audiobooks
//
//  Created by Rasmus Krämer on 03.10.23.
//

import Foundation
import SPFoundation

public extension AudiobookshelfClient {
    func home(for libraryID: String) async throws -> ([HomeRow<Audiobook>], [HomeRow<Author>]) {
        let response = try await request(ClientRequest<[HomeRowPayload]>(path: "api/libraries/\(libraryID)/personalized", method: "GET"))
        
        var authors = [HomeRow<Author>]()
        var audiobooks = [HomeRow<Audiobook>]()
        
        for row in response {
            if row.entities.isEmpty {
                continue
            }
            
            if row.type == "book" {
                audiobooks.append(HomeRow(id: row.id, label: row.label, entities: row.entities.compactMap(Audiobook.init)))
            } else if row.type == "authors" {
                authors.append(HomeRow(id: row.id, label: row.label, entities: row.entities.map(Author.init)))
            }
        }
        
        return (audiobooks, authors)
    }
    
    func audiobooks(from libraryID: String, sortOrder: AudiobookSortOrder, ascending: Bool, groupSeries: Bool = false, limit: Int?, page: Int?) async throws -> ([AudiobookSection], Int) {
        var query: [URLQueryItem] = [
            .init(name: "sort", value: sortOrder.queryValue),
            .init(name: "desc", value: ascending ? "0" : "1"),
            .init(name: "collapseseries", value: groupSeries ? "1" : "0"),
        ]
        
        if let page {
            query.append(.init(name: "page", value: String(describing: page)))
        }
        if let limit {
            query.append(.init(name: "limit", value: String(describing: limit)))
        }
        
        let result = try await request(ClientRequest<ResultResponse>(path: "api/libraries/\(libraryID)/items", method: "GET", query: query))
        return (result.results.compactMap(AudiobookSection.parse), result.total)
    }
}
