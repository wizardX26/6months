import SwiftUI

struct ChipPageGridView: View {
    let page: ChipPage

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, alignment: .leading, spacing: 12) {
                ForEach(page.cards) { card in
                    ChipPageCardView(card: card)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 4)
            .padding(.bottom, 28)
        }
    }
}

private struct ChipPageCardView: View {
    let card: ChipPageCard

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: card.systemImageName)
                .font(.title2.weight(.semibold))
                .foregroundStyle(card.accentColor)
                .frame(width: 34, height: 34)
                .background(card.accentColor.opacity(0.14), in: Circle())

            VStack(alignment: .leading, spacing: 5) {
                Text(card.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                Text(card.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 148, alignment: .topLeading)
        .background(.background, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(.separator.opacity(0.75), lineWidth: 1)
        }
    }
}

struct ChipPage: Identifiable, Hashable {
    let id: String
    var title: String
    var systemImageName: String
    var cards: [ChipPageCard]
}

struct ChipPageCard: Identifiable, Hashable {
    let id: String
    var title: String
    var subtitle: String
    var systemImageName: String
    var accentColor: Color
}
