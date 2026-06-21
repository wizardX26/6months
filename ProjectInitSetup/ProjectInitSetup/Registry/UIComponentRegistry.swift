import UIKit

enum UIComponentRegistry {
    private(set) static var makeNavigationBar: ((NavigationBarPresentationData) -> NavigationBarProtocol)?
    private(set) static var makeTabBar: ((TabBarTheme) -> CustomTabBarView)?

    static func registerAll() {
        registerNavigationBar { presentationData in
            CustomNavigationBar(presentationData: presentationData)
        }
        registerTabBar { theme in
            CustomTabBarView(theme: theme)
        }
    }

    static func registerNavigationBar(_ factory: @escaping (NavigationBarPresentationData) -> NavigationBarProtocol) {
        makeNavigationBar = factory
    }

    static func registerTabBar(_ factory: @escaping (TabBarTheme) -> CustomTabBarView) {
        makeTabBar = factory
    }
}
