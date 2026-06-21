import UIKit

@objc protocol NavigationBarDelegate: AnyObject {
    @objc optional func navigationBar(_ bar: CustomNavigationBar, leftAction sender: Any)
    @objc optional func navigationBar(_ bar: CustomNavigationBar, firstRightAction sender: Any)
    @objc optional func navigationBar(_ bar: CustomNavigationBar, secondRightAction sender: Any)
    @objc optional func navigationBar(_ bar: CustomNavigationBar, searchEditingChanged keyword: String)
    @objc optional func navigationBar(_ bar: CustomNavigationBar, searchEditingDidEnd keyword: String)
}
