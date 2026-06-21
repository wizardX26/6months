import RxSwift
import UIKit

final class TabBarController: BaseViewController {
    private(set) var selectedIndex: Int = 0
    private var phase: TabSwitchPhase = .idle(selectedIndex: 0)
    private var isTabBarDrivingPager = false

    let pager = TabPagerContainer()
    private var tabBarView: CustomTabBarView!
    private let session: SessionContext
    private var tabViewControllers: [UIViewController] = []
    private var selectedReadySubject = BehaviorSubject<Bool>(value: false)
    private var presentationDisposeBag = DisposeBag()

    var selectedViewControllerReady: Observable<Bool> {
        selectedReadySubject
            .distinctUntilChanged()
            .filter { $0 }
            .take(1)
            .startWith(false)
    }

    init(session: SessionContext) {
        self.session = session
        super.init(navigationBarPresentationData: nil)

        let theme = TabBarTheme(appTheme: .light)
        tabBarView = UIComponentRegistry.makeTabBar?(theme) ?? CustomTabBarView(theme: theme)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tabBarView.delegate = self
        pager.delegate = self

        view.addSubview(pager)
        view.addSubview(tabBarView)

        session.shared.presentationData
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] data in
                self?.applyPresentationData(data)
            })
            .disposed(by: presentationDisposeBag)
    }

    func setViewControllers(_ controllers: [UIViewController], selectedIndex: Int) {
        tabViewControllers = controllers
        self.selectedIndex = selectedIndex
        phase = .idle(selectedIndex: selectedIndex)

        let strings = PresentationData.default.strings
        tabBarView.configure(
            items: [strings.tabHome, strings.tabExplore, strings.tabProfile],
            selectedIndex: selectedIndex
        )

        pager.setViewControllers(controllers, parent: self, selectedIndex: selectedIndex)
        bindSelectedViewControllerReady()
        markReady()
    }

    override func containerLayoutUpdated(_ layout: ContainerViewLayout, transition: LayoutTransition) {
        let bottomSafe = layout.safeAreaInsets.bottom
        let tabBarHeight = tabBarView.preferredHeight(bottomInset: bottomSafe)
        var childLayout = layout
        childLayout.intrinsicInsets.bottom = tabBarHeight

        tabBarView.layoutTabBar(width: layout.size.width, bottomInset: bottomSafe, transition: transition)
        pager.containerLayoutUpdated(childLayout, transition: transition)
        updateValidLayout(childLayout)
    }

    private func applyPresentationData(_ data: PresentationData) {
        view.backgroundColor = data.theme.backgroundColor
        tabBarView.updateTheme(TabBarTheme(appTheme: data.theme))
    }

    private func bindSelectedViewControllerReady() {
        guard let selected = pager.selectedViewController() else {
            selectedReadySubject.onNext(true)
            return
        }
        if let ready = selected as? ReadyProviding {
            ready.isReady
                .filter { $0 }
                .take(1)
                .subscribe(onNext: { [weak self] _ in
                    self?.selectedReadySubject.onNext(true)
                })
                .disposed(by: disposeBag)
        } else {
            selectedReadySubject.onNext(true)
        }
    }

    private func propagateLayoutToSelectedTab() {
        guard let layout = validLayout else { return }
        pager.containerLayoutUpdated(layout, transition: .immediate)
    }

    private func pagerDidUpdateProgress(_ progress: CGFloat, from: Int, to: Int) {
        guard !isTabBarDrivingPager else { return }
        phase = .paging(from: from, to: to, progress: progress)
    }

    private func pagerDidCommitTo(_ index: Int) {
        selectedIndex = index
        phase = .idle(selectedIndex: index)
        isTabBarDrivingPager = false
        tabBarView.setSelectedIndex(index, animated: true)
        bindSelectedViewControllerReady()
        propagateLayoutToSelectedTab()
        UIAccessibility.post(notification: .layoutChanged, argument: tabBarView)
    }
}

extension TabBarController: CustomTabBarViewDelegate {
    func tabBarView(_ tabBar: CustomTabBarView, didSelect index: Int) {
        guard index != selectedIndex else { return }
        isTabBarDrivingPager = false
        pager.scrollToIndex(index, animated: true) { [weak self] in
            self?.pagerDidCommitTo(index)
        }
    }

    func tabBarView(_ tabBar: CustomTabBarView, didUpdateDragProgress progress: CGFloat, from: Int, to: Int) {
        isTabBarDrivingPager = true
        phase = .paging(from: from, to: to, progress: progress)
        if from != to {
            pager.updateInteractiveTransition(progress: progress, from: from, to: to)
        }
    }

    func tabBarView(_ tabBar: CustomTabBarView, didCommitDragTo index: Int) {
        isTabBarDrivingPager = true
        pager.commitInteractiveTransition(to: index, animated: true) { [weak self] in
            self?.pagerDidCommitTo(index)
        }
    }

    func tabBarView(_ tabBar: CustomTabBarView, didPerformContextAction action: TabBarContextAction, forTabAt index: Int) {
        let message: String
        switch action {
        case .pin:
            message = "Pinned tab at index \(index)"
        case .markRead:
            message = "Marked tab \(index) as read"
        case .hide:
            message = "Hide requested for tab \(index)"
        }
        let alert = UIAlertController(title: action.rawValue, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension TabBarController: TabPagerContainerDelegate {
    func pager(_ pager: TabPagerContainer, didUpdateProgress progress: CGFloat, from: Int, to: Int) {
        pagerDidUpdateProgress(progress, from: from, to: to)
    }

    func pager(_ pager: TabPagerContainer, didCommitTo index: Int) {
        pagerDidCommitTo(index)
    }

    func pagerShouldBeginPaging(_ pager: TabPagerContainer) -> Bool {
        guard !isTabBarDrivingPager else { return false }
        guard let selected = pager.selectedViewController() else { return true }
        if let nav = selected as? UINavigationController {
            return nav.viewControllers.count <= 1
        }
        if let nav = selected.navigationController, selected !== nav.viewControllers.first {
            return false
        }
        return true
    }
}
