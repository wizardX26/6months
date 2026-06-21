import UIKit

class BaseViewController: UIViewController {

    var customNavigationBar: CustomNavigationBar?
    var navigationTitleStyle: TitleStyle = .inline
    var statusBarStyle: UIStatusBarStyle = .lightContent {
        didSet { setNeedsStatusBarAppearanceUpdate() }
    }
    var isSwipeBackEnabled: Bool = true {
        didSet { updateInteractivePopGesture() }
    }

    private var navigationBarHeightConstraint: NSLayoutConstraint?
    private var navigationLayoutCache = NavigationLayoutCache()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        statusBarStyle
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateNavigationBarLayoutIfNeeded()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateInteractivePopGesture()
        syncStatusBarFromNavigationBar()
        updateNavigationBarLayoutIfNeeded()
    }
}

// MARK: - Navigation bar

private struct NavigationLayoutCache: Equatable {
    var context: NavigationBarLayoutContext = .standard
    var barHeight: CGFloat = 0
    var safeAreaTop: CGFloat = -1
}

extension BaseViewController {
    func setupNavigationBar(
        owner: UIViewController,
        title: String,
        type: NavigationType = .backButton,
        titleStyle: TitleStyle = .inline,
        isPush: Bool = true,
        hasBackground: Bool = true
    ) {
        navigationTitleStyle = titleStyle

        if customNavigationBar == nil {
            let bar = CustomNavigationBar.loadFromNib(
                width: view.bounds.width,
                height: LayoutHelper.navigationBarHeight(titleStyle: titleStyle, for: self)
            )
            bar.delegate = owner as? NavigationBarDelegate
            view.addSubview(bar)
            customNavigationBar = bar
        }

        customNavigationBar?.title = title
        customNavigationBar?.type = type
        customNavigationBar?.titleStyle = titleStyle
        customNavigationBar?.isPush = isPush
        customNavigationBar?.hasBackground = hasBackground

        updateNavigationBarLayoutIfNeeded()
    }

    func pinNavigationBarToTop() {
        guard let bar = customNavigationBar else { return }
        bar.translatesAutoresizingMaskIntoConstraints = false

        let heightConstraint = bar.heightAnchor.constraint(
            equalToConstant: LayoutHelper.navigationBarHeight(titleStyle: navigationTitleStyle, for: self)
        )
        navigationBarHeightConstraint = heightConstraint

        NSLayoutConstraint.activate([
            bar.topAnchor.constraint(equalTo: view.topAnchor),
            bar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            heightConstraint
        ])
    }

    func updateNavigationBarLayoutIfNeeded() {
        guard customNavigationBar != nil else { return }

        let context = LayoutHelper.navigationBarLayoutContext(for: self)
        let safeTop = LayoutHelper.safeAreaTop(for: view)
        let height = NavigationBarMetrics.barHeight(
            titleStyle: navigationTitleStyle,
            context: context,
            safeAreaTop: safeTop
        )

        let newCache = NavigationLayoutCache(context: context, barHeight: height, safeAreaTop: safeTop)
        guard newCache != navigationLayoutCache else { return }
        navigationLayoutCache = newCache

        if customNavigationBar?.layoutContext != context {
            customNavigationBar?.layoutContext = context
        }
        if navigationBarHeightConstraint?.constant != height {
            navigationBarHeightConstraint?.constant = height
        }
    }

    func syncStatusBarFromNavigationBar() {
        guard let bar = customNavigationBar else { return }
        let style = bar.statusBarStyle
        if style != statusBarStyle {
            statusBarStyle = style
        }
    }

    func updateInteractivePopGesture() {
        guard let nav = navigationController else { return }
        let canSwipeBack = isSwipeBackEnabled && nav.viewControllers.count > 1
        nav.interactivePopGestureRecognizer?.isEnabled = canSwipeBack
        nav.interactivePopGestureRecognizer?.delegate = self
    }
}

extension BaseViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer === navigationController?.interactivePopGestureRecognizer else {
            return true
        }
        guard let nav = navigationController else { return false }
        return isSwipeBackEnabled && nav.viewControllers.count > 1
    }
}
