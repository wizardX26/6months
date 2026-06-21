import RxSwift
import UIKit

enum NavigationPresentation {
    case `default`
    case modal
    case fullScreen
}

class BaseViewController: UIViewController, ContainerLayoutParticipant, ReadyProviding {
    let navigationBarView: NavigationBarProtocol?
    private(set) var validLayout: ContainerViewLayout?
    let disposeBag = DisposeBag()

    private let readyState = ReadyStateHolder()
    var isReady: Observable<Bool> { readyState.isReady }

    var navigationPresentation: NavigationPresentation { .default }

    init(navigationBarPresentationData: NavigationBarPresentationData?) {
        if let data = navigationBarPresentationData {
            navigationBarView = UIComponentRegistry.makeNavigationBar?(data)
        } else {
            navigationBarView = nil
        }
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        if let bar = navigationBarView {
            view.addSubview(bar)
        }

        layoutContentIfNeeded()
        markReady()
    }

    func markReady() {
        readyState.markReady()
    }

    func updateValidLayout(_ layout: ContainerViewLayout) {
        validLayout = layout
    }

    func containerLayoutUpdated(_ layout: ContainerViewLayout, transition: LayoutTransition) {
        validLayout = layout
        applyNavigationBarLayout(layout, transition: transition)
        layoutContent(layout, transition: transition)
    }

    /// Override in subclasses to position content. Do not call `containerLayoutUpdated` from here.
    func layoutContent(_ layout: ContainerViewLayout, transition: LayoutTransition) {}

    func applyNavigationBarLayout(_ layout: ContainerViewLayout, transition: LayoutTransition) {
        guard let bar = navigationBarView else { return }
        let topInset = layout.insets(options: .statusBar).top
        bar.layoutNavigationBar(width: layout.size.width, insets: UIEdgeInsets(top: topInset, left: 0, bottom: 0, right: 0), transition: transition)
    }

    func contentFrame(for layout: ContainerViewLayout) -> CGRect {
        let topInset: CGFloat
        if navigationBarView != nil {
            topInset = layout.insets(options: .statusBar).top + 44
        } else {
            topInset = layout.insets(options: .statusBar).top
        }
        let bottomInset = layout.intrinsicInsets.bottom
        return CGRect(
            x: 0,
            y: topInset,
            width: layout.size.width,
            height: max(0, layout.size.height - topInset - bottomInset)
        )
    }

    private func layoutContentIfNeeded() {
        guard let layout = validLayout else { return }
        applyNavigationBarLayout(layout, transition: .immediate)
        layoutContent(layout, transition: .immediate)
    }
}
