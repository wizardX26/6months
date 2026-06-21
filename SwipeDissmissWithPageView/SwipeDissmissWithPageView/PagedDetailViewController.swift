//
//  PagedDetailViewController.swift
//  SwipeDissmissWithPageView
//

import UIKit

final class PagedDetailViewController: UIViewController {

    private let containerView = UIView()
    private let pageControl = UIPageControl()
    private let pageViewController = UIPageViewController(
        transitionStyle: .scroll,
        navigationOrientation: .horizontal
    )
    private let popTransitionController = InteractivePopTransitionController()

    private var pages: [PageContentViewController] = []
    private var currentIndex = 0
    private var popPipeline: InteractivePopPipeline?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Paged Detail"
        view.backgroundColor = .systemBackground

        setupPages()
        setupLayout()
        setupPageViewController()
        setupPopPipeline()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let navigationController {
            popTransitionController.attach(to: navigationController)
        }
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent, !popTransitionController.isInteractivePopActive {
            navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        }
    }

    private func setupPages() {
        pages = [
            PageContentViewController(
                pageIndex: 0,
                titleText: "Page 0 — Feed",
                accentColor: .systemBlue,
                showsScrollableContent: true
            ),
            PageContentViewController(
                pageIndex: 1,
                titleText: "Page 1 — Media",
                accentColor: .systemOrange
            ),
            PageContentViewController(
                pageIndex: 2,
                titleText: "Page 2 — Info",
                accentColor: .systemGreen
            ),
        ]
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.isUserInteractionEnabled = false
    }

    private func setupLayout() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        pageControl.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(containerView)
        view.addSubview(pageControl)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: pageControl.topAnchor, constant: -8),

            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
        ])
    }

    private func setupPageViewController() {
        addChild(pageViewController)
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(pageViewController.view)

        NSLayoutConstraint.activate([
            pageViewController.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            pageViewController.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
        ])

        pageViewController.didMove(toParent: self)
        pageViewController.dataSource = self
        pageViewController.delegate = self

        if let firstPage = pages.first {
            pageViewController.setViewControllers([firstPage], direction: .forward, animated: false)
        }

        configurePageScrollViews()
    }

    private func configurePageScrollViews() {
        for scrollView in pageViewController.view.subviews.compactMap({ $0 as? UIScrollView }) {
            scrollView.delaysContentTouches = false
        }
    }

    private var pageScrollView: UIScrollView? {
        pageViewController.view.subviews.compactMap { $0 as? UIScrollView }.first
    }

    private func setupPopPipeline() {
        let pipeline = InteractivePopPipeline(on: containerView)
        pipeline.currentPageIndex = { [weak self] in
            self?.currentIndex ?? 0
        }
        pipeline.canPop = { [weak self] in
            (self?.navigationController?.viewControllers.count ?? 0) > 1
        }
        pipeline.pageView = pageViewController.view
        pipeline.pageScrollPan = pageScrollView?.panGestureRecognizer
        pipeline.onPop = { [weak self] state in
            self?.handleInteractivePop(state)
        }
        popPipeline = pipeline
    }

    private func setPageViewInteractionEnabled(_ enabled: Bool) {
        pageViewController.view.isUserInteractionEnabled = enabled
        if enabled {
            pageViewController.dataSource = self
        } else {
            pageViewController.dataSource = nil
        }
    }

    private func handleInteractivePop(_ state: InteractivePopPipeline.PopState) {
        switch state {
        case .began:
            popTransitionController.beginInteractivePop()
            setPageViewInteractionEnabled(false)

        case let .changed(_, progress):
            popTransitionController.update(progress: progress)

        case let .ended(_, _, shouldComplete):
            setPageViewInteractionEnabled(true)
            popTransitionController.end(shouldComplete: shouldComplete)

        case .cancelled:
            setPageViewInteractionEnabled(true)
            popTransitionController.cancelInteractivePop()
        }
    }

    private func index(of viewController: UIViewController) -> Int? {
        pages.firstIndex { $0 === viewController }
    }
}

extension PagedDetailViewController: UIPageViewControllerDataSource {

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let index = index(of: viewController), index > 0 else { return nil }
        return pages[index - 1]
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let index = index(of: viewController), index < pages.count - 1 else { return nil }
        return pages[index + 1]
    }
}

extension PagedDetailViewController: UIPageViewControllerDelegate {

    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        guard completed,
              let visible = pageViewController.viewControllers?.first,
              let index = index(of: visible) else { return }
        currentIndex = index
        pageControl.currentPage = index
    }
}
