//
//  AudiobookshelfClient+Podcasts.swift
//  Audiobooks
//
//  Created by Rasmus Krämer on 07.10.23.
//

import Foundation
import SPFoundation

public extension AudiobookshelfClient {
    func home(libraryID: String) async throws -> ([HomeRow<Podcast>], [HomeRow<Episode>]) {
        let response = try await request(ClientRequest<[AudiobookshelfHomeRow]>(path: "api/libraries/\(libraryID)/personalized", method: "GET"))
        
        var episodes = [HomeRow<Episode>]()
        var podcasts = [HomeRow<Podcast>]()
        
        for row in response {
            if row.entities.isEmpty {
                continue
            }
            
            if row.type == "episode" {
                episodes.append(HomeRow(id: row.id, label: row.label, entities: row.entities.compactMap(Episode.init)))
            } else if row.type == "podcast" {
                podcasts.append(HomeRow(id: row.id, label: row.label, entities: row.entities.map(Podcast.init)))
            }
        }
        
        return (podcasts, episodes)
    }
    
    func podcast(podcastId: String) async throws -> (Podcast, [Episode]) {
        let item = try await request(ClientRequest<AudiobookshelfItem>(path: "api/items/\(podcastId)", method: "GET"))
        let podcast = Podcast(item: item)
        
        guard let episodes = item.media?.episodes else {
            throw ClientError.invalidResponse
        }
            
        return (podcast, episodes.compactMap { Episode(episode: $0, item: item) })
        
    }
    
    func podcasts(libraryID: String, limit: Int?, page: Int?) async throws -> ([Podcast], Int) {
        var query: [URLQueryItem] = []
        
        if let page {
            query.append(.init(name: "page", value: String(page)))
        }
        if let limit {
            query.append(.init(name: "limit", value: String(limit)))
        }
        
        query.append(.init(name: "include", value: "numEpisodesIncomplete"))
        
        let response = try await request(ClientRequest<ResultResponse>(path: "api/libraries/\(libraryID)/items", method: "GET", query: query))
        return (response.results.map(Podcast.init), response.total)
    }
}
