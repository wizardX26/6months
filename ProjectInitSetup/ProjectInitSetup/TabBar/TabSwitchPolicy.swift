import UIKit

enum TabSwitchPhase: Equatable {
    case idle(selectedIndex: Int)
    case paging(from: Int, to: Int, progress: CGFloat)
    case committing(to: Int)
}

struct TabSwitchPolicy {
    static func resolveTargetIndex(
        currentIndex: Int,
        pageCount: Int,
        progress: CGFloat,
        velocity: CGPoint,
        direction: Int
    ) -> Int {
        guard pageCount > 0 else { return 0 }

        let threshold: CGFloat = 0.35
        var target = currentIndex

        if direction > 0, currentIndex < pageCount - 1 {
            target = progress > threshold || abs(velocity.x) > 300 ? currentIndex + 1 : currentIndex
        } else if direction < 0, currentIndex > 0 {
            target = progress > threshold || abs(velocity.x) > 300 ? currentIndex - 1 : currentIndex
        }

        return min(max(target, 0), pageCount - 1)
    }
}
