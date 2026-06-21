import UIKit

protocol AppBindings: AnyObject {
    var isActive: Bool { get }
    func openURL(_ url: URL)
}

final class AppBindingsImpl: AppBindings {
    var isActive: Bool {
        UIApplication.shared.applicationState == .active
    }

    func openURL(_ url: URL) {
        UIApplication.shared.open(url)
    }
}
