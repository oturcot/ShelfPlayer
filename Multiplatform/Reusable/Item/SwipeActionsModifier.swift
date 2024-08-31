//
//  SwipeActionsModifier.swift
//  Audiobooks
//
//  Created by Rasmus Krämer on 13.10.23.
//

import SwiftUI
import ShelfPlayerKit
import SPPlayback

struct SwipeActionsModifier: ViewModifier {
    let item: PlayableItem
    
    @Binding var loading: Bool
    
    func body(content: Content) -> some View {
        content
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                DownloadButton(item: item, tint: true)
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                ProgressButton(item: item, tint: true)
            }
            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                Button {
                    Task {
                        loading = true
                        try await AudioPlayer.shared.play(item)
                        loading = false
                    }
                } label: {
                    Label("play", systemImage: "play")
                }
                .tint(.accentColor)
            }
            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                Button {
                    AudioPlayer.shared.queue(item)
                } label: {
                    Label("queue.last", systemImage: "text.line.last.and.arrowtriangle.forward")
                }
                .tint(.orange)
            }
    }
}
