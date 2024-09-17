//
//  AudiobookSeriesView.swift
//  Multiplatform
//
//  Created by Rasmus Krämer on 23.04.24.
//

import SwiftUI
import Defaults
import ShelfPlayerKit

internal struct AudiobookSeriesPanel: View {
    @Environment(\.libraryId) private var libraryId
    @Default(.seriesDisplay) private var seriesDisplay
    
    @State private var lazyLoader = LazyLoadHelper<Series, Void>.series
    
    var body: some View {
        Group {
            if lazyLoader.items.isEmpty {
                if lazyLoader.failed {
                    ErrorView()
                        .refreshable {
                            await lazyLoader.refresh()
                        }
                } else {
                    LoadingView()
                        .onAppear {
                            lazyLoader.initialLoad()
                        }
                }
            } else {
                Group {
                    switch seriesDisplay {
                        case .grid:
                            ScrollView {
                                SeriesGrid(series: lazyLoader.items) {
                                    if $0 == lazyLoader.items.last {
                                        lazyLoader.didReachEndOfLoadedContent()
                                    }
                                }
                                .padding(20)
                            }
                        case .list:
                            List {
                                SeriesList(series: lazyLoader.items) {
                                    if $0 == lazyLoader.items[max(0, lazyLoader.items.endIndex - 4)] {
                                        lazyLoader.didReachEndOfLoadedContent()
                                    }
                                }
                            }
                            .listStyle(.plain)
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            withAnimation {
                                seriesDisplay = seriesDisplay == .list ? .grid : .list
                            }
                        } label: {
                            Label("sort.\(seriesDisplay == .list ? "list" : "grid")", systemImage: seriesDisplay == .list ? "list.bullet" : "square.grid.2x2")
                        }
                    }
                }
                .refreshable {
                    await lazyLoader.refresh()
                }
            }
        }
        .navigationTitle("title.series")
        .modifier(NowPlaying.SafeAreaModifier())
        .onAppear {
            lazyLoader.libraryID = libraryId
        }
    }
}

#Preview {
    AudiobookSeriesPanel()
}
