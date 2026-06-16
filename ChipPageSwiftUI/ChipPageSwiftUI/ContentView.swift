//
//  ContentView.swift
//  ChipPageSwiftUI
//
//  Created by wizard.os25 on 8/6/26.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedPageIndex = 0

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Chip Page")
                        .font(.largeTitle.bold())

                    Text("Selected: \(selectedPage.title)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 20)

                ChipCollectionView(
                    items: chipItems,
                    selection: selectedChipID,
                    onSelect: selectChip(id:)
                )
                .frame(height: 56)

                TabView(selection: $selectedPageIndex) {
                    ForEach(Array(ChipPageMockData.pages.enumerated()), id: \.element.id) { index, page in
                        ChipPageGridView(page: page)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.snappy, value: selectedPageIndex)
            }
            .padding(.vertical, 28)
            .navigationTitle("UIKit Bridge")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var chipItems: [ChipCollectionItem] {
        ChipPageMockData.pages.map { page in
            ChipCollectionItem(
                id: page.id,
                title: page.title,
                systemImageName: page.systemImageName
            )
        }
    }

    private var selectedChipID: ChipCollectionItem.ID? {
        selectedPage.id
    }

    private var selectedPage: ChipPage {
        ChipPageMockData.pages[
            min(max(selectedPageIndex, 0), ChipPageMockData.pages.count - 1)
        ]
    }

    private func selectChip(id: ChipCollectionItem.ID) {
        guard let index = ChipPageMockData.pages.firstIndex(where: { $0.id == id }) else {
            return
        }

        selectedPageIndex = index
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
