//
//  SeriesView.swift
//  Audiobooks
//
//  Created by Rasmus Krämer on 05.10.23.
//

import SwiftUI
import Defaults
import ShelfPlayerKit

internal struct SeriesView: View {
    @Environment(\.library) private var library
    
    @State private var viewModel: SeriesViewModel
    
    init(_ series: Series) {
        viewModel = .init(series: series)
    }
    
    var body: some View {
        Group {
            switch viewModel.displayMode {
            case .grid:
                ScrollView {
                    Header()
                    
                    HStack {
                        RowTitle(title: String(localized: "books"), fontDesign: .serif)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    
                    AudiobookVGrid(sections: viewModel.visible) {
                        if $0 == viewModel.visible.last {
                            viewModel.lazyLoader.didReachEndOfLoadedContent()
                        }
                    }
                    .padding(.horizontal, 20)
                }
            case .list:
                List {
                    Header()
                        .listRowSeparator(.hidden)
                        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    
                    RowTitle(title: String(localized: "books"), fontDesign: .serif)
                        .listRowSeparator(.hidden, edges: .top)
                        .listRowInsets(.init(top: 16, leading: 20, bottom: 0, trailing: 20))
                    
                    AudiobookList(sections: viewModel.visible) {
                        if $0 == viewModel.visible[max(0, viewModel.visible.endIndex - 4)] {
                            viewModel.lazyLoader.didReachEndOfLoadedContent()
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle(viewModel.series.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                AudiobookSortFilter(filter: $viewModel.filter, displayType: $viewModel.displayMode, sortOrder: $viewModel.sortOrder, ascending: $viewModel.ascending) {
                    viewModel.lazyLoader.sortOrder = viewModel.sortOrder
                    viewModel.lazyLoader.ascending = viewModel.ascending
                    
                    await viewModel.lazyLoader.refresh()
                }
            }
        }
        .environment(viewModel)
        .modifier(NowPlaying.SafeAreaModifier())
        .onAppear {
            viewModel.library = library
            viewModel.lazyLoader.initialLoad()
        }
        .refreshable {
            await viewModel.lazyLoader.refresh()
        }
        .userActivity("io.rfk.shelfplayer.series") {
            $0.title = viewModel.series.id
            $0.isEligibleForHandoff = true
            $0.persistentIdentifier = viewModel.series.name
            $0.targetContentIdentifier = convertIdentifier(item: viewModel.series)
            $0.userInfo = [
                "libraryID": viewModel.series.libraryID,
                "seriesID": viewModel.series.id,
                "seriesName": viewModel.series.name,
            ]
            $0.webpageURL = viewModel.series.url
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        SeriesView(.fixture)
    }
    .environment(NowPlaying.ViewModel())
}
#endif
