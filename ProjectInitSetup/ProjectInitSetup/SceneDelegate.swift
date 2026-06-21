//
//  SceneDelegate.swift
//  ProjectInitSetup
//

import RxSwift
import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var bootstrap: BootstrapCoordinator?
    private var disposeBag = DisposeBag()

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let appWindow = AppWindow(windowScene: windowScene)
        window = appWindow
        appWindow.makeKeyAndVisible()
        appWindow.showCovering(SplashViewController())

        let bootstrap = BootstrapCoordinator(window: appWindow)
        self.bootstrap = bootstrap
        bootstrap.start()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { rootController in
                appWindow.setRootViewController(rootController, animated: true)
                appWindow.hideCovering(animated: true)
                appWindow.layoutRoot = rootController as? ContainerLayoutParticipant
            })
            .disposed(by: disposeBag)
    }
}
