//
//  BookmarksView.swift
//  Ferrite
//
//  Created by Brian Dashore on 9/2/22.
//

import SwiftUI

struct BookmarksView: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass

    @EnvironmentObject var navModel: NavigationViewModel
    @EnvironmentObject var debridManager: DebridManager

    let backgroundContext = PersistenceController.shared.backgroundContext

    var bookmarks: FetchedResults<Bookmark>

    @State private var viewTask: Task<Void, Never>?

    var body: some View {
        ZStack {
            if !bookmarks.isEmpty {
                List {
                    ForEach(bookmarks, id: \.self) { bookmark in
                        SearchResultButtonView(result: bookmark.toSearchResult(), existingBookmark: bookmark)
                    }
                    .onDelete { offsets in
                        for index in offsets {
                            if let bookmark = bookmarks[safe: index] {
                                PersistenceController.shared.delete(bookmark, context: backgroundContext)

                                NotificationCenter.default.post(name: .didDeleteBookmark, object: bookmark)
                            }
                        }
                    }
                    .onMove { source, destination in
                        var changedBookmarks = bookmarks.map { $0 }

                        changedBookmarks.move(fromOffsets: source, toOffset: destination)

                        for reverseIndex in stride(from: changedBookmarks.count - 1, through: 0, by: -1) {
                            changedBookmarks[reverseIndex].orderNum = Int16(reverseIndex)
                        }

                        PersistenceController.shared.save()
                    }
                }
                .inlinedList()
                .listStyle(.insetGrouped)
            }
        }
        .onAppear {
            if debridManager.enabledDebrids.count > 0 {
                viewTask = Task {
                    let magnets = bookmarks.compactMap {
                        if let magnetHash = $0.magnetHash {
                            return Magnet(hash: magnetHash, link: $0.magnetLink)
                        } else {
                            return nil
                        }
                    }
                    await debridManager.populateDebridIA(magnets)
                }
            }
        }
        .onDisappear {
            viewTask?.cancel()
        }
    }
}
