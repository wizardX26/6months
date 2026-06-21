import UIKit

struct AppTheme: Equatable {
    let backgroundColor: UIColor
    let primaryTextColor: UIColor
    let secondaryTextColor: UIColor
    let accentColor: UIColor
    let navigationBarBackground: UIColor
    let tabBarBackground: UIColor
    let tabBarSelectedColor: UIColor
    let tabBarUnselectedColor: UIColor
    let separatorColor: UIColor

    static let light = AppTheme(
        backgroundColor: .systemBackground,
        primaryTextColor: .label,
        secondaryTextColor: .secondaryLabel,
        accentColor: .systemBlue,
        navigationBarBackground: .systemBackground,
        tabBarBackground: .systemBackground,
        tabBarSelectedColor: .systemBlue,
        tabBarUnselectedColor: .secondaryLabel,
        separatorColor: .separator
    )

    static let dark = AppTheme(
        backgroundColor: .black,
        primaryTextColor: .white,
        secondaryTextColor: .lightGray,
        accentColor: .systemBlue,
        navigationBarBackground: .black,
        tabBarBackground: .black,
        tabBarSelectedColor: .systemBlue,
        tabBarUnselectedColor: .gray,
        separatorColor: .darkGray
    )
}

struct AppStrings: Equatable {
    let homeTitle: String
    let exploreTitle: String
    let profileTitle: String
    let tabHome: String
    let tabExplore: String
    let tabProfile: String

    static let `default` = AppStrings(
        homeTitle: "Home",
        exploreTitle: "Explore",
        profileTitle: "Profile",
        tabHome: "Home",
        tabExplore: "Explore",
        tabProfile: "Profile"
    )
}

struct DateFormatConfig: Equatable {
    let localeIdentifier: String

    static let `default` = DateFormatConfig(localeIdentifier: Locale.current.identifier)
}

struct PresentationMetrics: Equatable {
    let navigationBarHeight: CGFloat
    let tabBarHeight: CGFloat

    static let `default` = PresentationMetrics(navigationBarHeight: 44, tabBarHeight: 49)
}

struct PresentationData: Equatable {
    let theme: AppTheme
    let strings: AppStrings
    let dateFormat: DateFormatConfig
    let metrics: PresentationMetrics

    static let `default` = PresentationData(
        theme: .light,
        strings: .default,
        dateFormat: .default,
        metrics: .default
    )

    init(settings: PresentationSettings) {
        self.theme = settings.isDarkMode ? .dark : .light
        self.strings = .default
        self.dateFormat = .default
        self.metrics = .default
    }

    init(theme: AppTheme, strings: AppStrings, dateFormat: DateFormatConfig, metrics: PresentationMetrics) {
        self.theme = theme
        self.strings = strings
        self.dateFormat = dateFormat
        self.metrics = metrics
    }
}

struct NavigationBarTheme: Equatable {
    let backgroundColor: UIColor
    let titleColor: UIColor
    let buttonColor: UIColor

    init(appTheme: AppTheme) {
        backgroundColor = appTheme.navigationBarBackground
        titleColor = appTheme.primaryTextColor
        buttonColor = appTheme.accentColor
    }
}

struct NavigationBarStrings: Equatable {
    let back: String

    init(appStrings: AppStrings) {
        back = "Back"
        _ = appStrings
    }
}

struct NavigationBarPresentationData {
    let theme: NavigationBarTheme
    let strings: NavigationBarStrings

    init(presentationData: PresentationData) {
        theme = NavigationBarTheme(appTheme: presentationData.theme)
        strings = NavigationBarStrings(appStrings: presentationData.strings)
    }
}

struct TabBarTheme: Equatable {
    let backgroundColor: UIColor
    let selectedColor: UIColor
    let unselectedColor: UIColor
    let separatorColor: UIColor

    init(appTheme: AppTheme) {
        backgroundColor = appTheme.tabBarBackground
        selectedColor = appTheme.tabBarSelectedColor
        unselectedColor = appTheme.tabBarUnselectedColor
        separatorColor = appTheme.separatorColor
    }
}

struct PresentationSettings: Equatable {
    let isDarkMode: Bool

    static let `default` = PresentationSettings(isDarkMode: false)
}
