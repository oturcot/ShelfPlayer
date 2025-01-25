//
//  AudiobookshelfClient+Authors.swift
//  Audiobooks
//
//  Created by Rasmus Krämer on 04.10.23.
//

import Foundation
import RFNetwork
import SPFoundation

public extension APIClient where I == ItemIdentifier.ConnectionID {
    func author(with identifier: ItemIdentifier) async throws -> Author {
        Author(payload: try await response(for: ClientRequest<ItemPayload>(path: "api/authors/\(identifier.pathComponent)", method: .get)), connectionID: connectionID)
    }
    
    func authors(from libraryID: String) async throws -> [Author] {
        try await response(for: ClientRequest<AuthorsResponse>(path: "api/libraries/\(libraryID)/authors", method: .get)).authors.map { Author(payload: $0, connectionID: connectionID) }
    }
    
    func authorID(from libraryID: String, name: String) async throws -> ItemIdentifier {
        let response = try await response(for: ClientRequest<SearchResponse>(path: "api/libraries/\(libraryID)/search", method: .get, query: [
            URLQueryItem(name: "q", value: name),
            URLQueryItem(name: "limit", value: "1"),
        ]))
        
        if let id = response.authors?.first?.id {
            return .init(primaryID: id,
                         groupingID: nil,
                         libraryID: libraryID,
                         connectionID: connectionID,
                         type: .author)
        }
        
        throw APIClientError.missing
    }
}
