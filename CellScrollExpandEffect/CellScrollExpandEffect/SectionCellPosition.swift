import UIKit

enum SectionCellPosition {
    case first
    case middle
    case last
    case single

    static let sectionCornerRadius: CGFloat = 16

    static func inSection(itemIndex: Int, itemCount: Int) -> SectionCellPosition {
        guard itemCount > 1 else { return .single }
        if itemIndex == 0 { return .first }
        if itemIndex == itemCount - 1 { return .last }
        return .middle
    }

    var maskedCorners: CACornerMask {
        switch self {
        case .first:
            return [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        case .last:
            return [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        case .single:
            return [
                .layerMinXMinYCorner, .layerMaxXMinYCorner,
                .layerMinXMaxYCorner, .layerMaxXMaxYCorner,
            ]
        case .middle:
            return []
        }
    }

    var uiRectCorners: UIRectCorner {
        switch self {
        case .first:
            return [.topLeft, .topRight]
        case .last:
            return [.bottomLeft, .bottomRight]
        case .single:
            return .allCorners
        case .middle:
            return []
        }
    }

    var appliesCornerRadius: Bool {
        self != .middle
    }
}
