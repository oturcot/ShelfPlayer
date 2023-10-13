//
//  AudiobooksList.swift
//  Audiobooks
//
//  Created by Rasmus Krämer on 06.10.23.
//

import SwiftUI

struct AudiobooksList: View {
    let audiobooks: [Audiobook]
    
    var body: some View {
        ForEach(audiobooks) { audiobook in
            NavigationLink(destination: AudiobookView(audiobook: audiobook)) {
                AudiobookRow(audiobook: audiobook)
            }
        }
    }
}

#Preview {
    NavigationStack {
        List {
            AudiobooksList(audiobooks: [
                Audiobook.fixture,
                Audiobook.fixture,
            ])
        }
        .listStyle(.plain)
    }
}
