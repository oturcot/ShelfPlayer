//
//  Item.swift
//  Audiobooks
//
//  Created by Rasmus Krämer on 02.10.23.
//

import Foundation

public class Item: Identifiable, @unchecked Sendable {
    public let id: ItemIdentifier
    
    public let name: String
    public let authors: [String]
    
    public let description: String?
    
    public let genres: [String]
    
    public let addedAt: Date
    public let released: String?
    
    init(id: ItemIdentifier, name: String, authors: [String], description: String?, genres: [String], addedAt: Date, released: String?) {
        self.id = id
        
        self.name = name
        self.authors = authors
        
        self.description = description
        
        self.genres = genres
        
        self.addedAt = addedAt
        self.released = released
    }
    
    var cover: Cover? {
        nil
    }
}

extension Item: Equatable {
    public static func == (lhs: Item, rhs: Item) -> Bool {
        lhs.id == rhs.id
    }
}

extension Item: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Item: Comparable {
    public static func <(lhs: Item, rhs: Item) -> Bool {
        lhs.sortName < rhs.sortName
    }
}

public extension Item {
    var sortName: String {
        get {
            var sortName = name.lowercased()
            
            if sortName.starts(with: "a ") {
                sortName = String(sortName.dropFirst(2))
            }
            if sortName.starts(with: "the ") {
                sortName = String(sortName.dropFirst(4))
            }
            
            sortName += " "
            sortName += authors.joined(separator: " ")
            
            return sortName
        }
    }
}
