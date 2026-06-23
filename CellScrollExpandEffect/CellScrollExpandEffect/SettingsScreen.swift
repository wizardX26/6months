import SwiftUI
import UIKit

private final class RevealedIDStore {
    private var ids = Set<String>()

    func isRevealed(_ id: String) -> Bool {
        ids.contains(id)
    }

    @discardableResult
    func markRevealed(_ id: String) -> Bool {
        guard !ids.contains(id) else { return false }
        ids.insert(id)
        return true
    }
}

struct SettingsScreen: View {
    @State private var revealStore = RevealedIDStore()

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(SettingsData.sections.indices, id: \.self) { sectionIndex in
                    sectionCard(sectionIndex: sectionIndex)
                }
            }
            .padding(.vertical, 16)
        }
        .background(Color(.systemGroupedBackground))
    }

    private func sectionCard(sectionIndex: Int) -> some View {
        LazyVStack(spacing: 0) {
            ForEach(Array(SettingsData.sections[sectionIndex].enumerated()), id: \.element.id) { itemIndex, item in
                SettingsRowView(
                    item: item,
                    rowID: SettingsData.rowID(section: sectionIndex, item: itemIndex),
                    position: SectionCellPosition.inSection(
                        itemIndex: itemIndex,
                        itemCount: SettingsData.sections[sectionIndex].count
                    ),
                    staggerIndex: globalStaggerIndex(section: sectionIndex, item: itemIndex),
                    revealStore: revealStore
                )

                if itemIndex < SettingsData.sections[sectionIndex].count - 1 {
                    Divider()
                        .padding(.leading, 56)
                }
            }
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.03), radius: 10, y: 2)
        .padding(.horizontal, 16)
    }

    private func globalStaggerIndex(section: Int, item: Int) -> Int {
        SettingsData.sections.prefix(section).reduce(0) { $0 + $1.count } + item
    }
}

private struct SettingsRowView: View {
    let item: SettingsItem
    let rowID: String
    let position: SectionCellPosition
    let staggerIndex: Int
    let revealStore: RevealedIDStore

    @State private var isVisible = false

    var body: some View {
        rowContent
            .modifier(SinkDownPressModifier())
            .opacity(isVisible ? 1 : 0)
            .scaleEffect(x: isVisible ? 1 : 0.0001, y: 1, anchor: .leading)
            .onAppear(perform: revealIfNeeded)
    }

    private var rowContent: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: item.systemImageName)
                .font(.system(size: 22))
                .foregroundStyle(.blue)
                .frame(width: 28, height: 28)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)

                Text(item.subtitle)
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 8)

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(SectionCellRowBackground(position: position))
        .contentShape(Rectangle())
    }

    private func revealIfNeeded() {
        if revealStore.isRevealed(rowID) {
            isVisible = true
            return
        }
        guard revealStore.markRevealed(rowID) else {
            isVisible = true
            return
        }

        let delay = min(Double(staggerIndex) * 0.04, 0.3)
        if delay == 0 {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.9)) {
                isVisible = true
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.9)) {
                    isVisible = true
                }
            }
        }
    }
}

private struct SinkDownPressModifier: ViewModifier {
    private let pressScale: CGFloat = 0.96
    private let pressOffsetY: CGFloat = 2

    @State private var isPressed = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? pressScale : 1)
            .offset(y: isPressed ? pressOffsetY : 0)
            .onLongPressGesture(
                minimumDuration: 0,
                maximumDistance: .infinity,
                pressing: { pressing in
                    withAnimation(pressing ? .easeOut(duration: 0.15) : .easeInOut(duration: 0.2)) {
                        isPressed = pressing
                    }
                },
                perform: {}
            )
    }
}

private struct SectionCellRowBackground: View {
    let position: SectionCellPosition

    var body: some View {
        Group {
            if position.appliesCornerRadius {
                Color(.tertiarySystemFill)
                    .clipShape(
                        SelectiveRoundedRectangle(
                            radius: SectionCellPosition.sectionCornerRadius,
                            corners: position.uiRectCorners
                        )
                    )
            } else {
                Color(.tertiarySystemFill)
            }
        }
    }
}

private struct SelectiveRoundedRectangle: Shape {
    let radius: CGFloat
    let corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        Path(
            UIBezierPath(
                roundedRect: rect,
                byRoundingCorners: corners,
                cornerRadii: CGSize(width: radius, height: radius)
            ).cgPath
        )
    }
}

#Preview {
    NavigationView {
        SettingsScreen()
            .navigationTitle("Cài đặt (SwiftUI)")
    }
}
