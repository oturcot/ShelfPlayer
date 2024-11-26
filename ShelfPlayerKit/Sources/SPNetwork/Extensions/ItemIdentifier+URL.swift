//
//  Untitled.swift
//  ShelfPlayerKit
//
//  Created by Rasmus Krämer on 26.11.24.
//

import Foundation
import SPFoundation

extension ItemIdentifier {
    var pathComponent: String {
        if let groupingID {
            "\(groupingID)/\(primaryID)"
        } else {
            primaryID
        }
    }
    
    public var url: URL {
        switch type {
        case .author:
            AudiobookshelfClient.shared.serverUrl.appending(path: "author").appending(path: primaryID)
        case .series:
            AudiobookshelfClient.shared.serverUrl.appending(path: "library").appending(path: libraryID).appending(path: "series").appending(path: primaryID)
        default:
            AudiobookshelfClient.shared.serverUrl.appending(path: "item").appending(path: primaryID)
        }
     }
}
