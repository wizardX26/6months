//
//  UIView+GestureNavigation.swift
//  GlassUIKit
//
//  Copyright (C) 2026 wizardOs contributors
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 2 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program. If not, see <https://www.gnu.org/licenses/>.
//

import ObjectiveC
import UIKit

struct UIResponderDisableAutomaticKeyboardHandling: OptionSet {
    let rawValue: Int

    static let forward = UIResponderDisableAutomaticKeyboardHandling(rawValue: 1 << 0)
    static let backward = UIResponderDisableAutomaticKeyboardHandling(rawValue: 1 << 1)
}

private enum GestureNavigationAssociatedKeys {
    static var disablesInteractiveTransition: UInt8 = 0
    static var disablesInteractiveKeyboard: UInt8 = 0
    static var disablesInteractiveModalDismiss: UInt8 = 0
    static var disablesInteractiveTransitionNow: UInt8 = 0
    static var interactiveTransitionTest: UInt8 = 0
    static var disableAutomaticKeyboardHandling: UInt8 = 0
}

extension UIView {
    var disablesInteractiveTransitionGestureRecognizer: Bool {
        get { (objc_getAssociatedObject(self, &GestureNavigationAssociatedKeys.disablesInteractiveTransition) as? Bool) ?? false }
        set { objc_setAssociatedObject(self, &GestureNavigationAssociatedKeys.disablesInteractiveTransition, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    var disablesInteractiveKeyboardGestureRecognizer: Bool {
        get { (objc_getAssociatedObject(self, &GestureNavigationAssociatedKeys.disablesInteractiveKeyboard) as? Bool) ?? false }
        set { objc_setAssociatedObject(self, &GestureNavigationAssociatedKeys.disablesInteractiveKeyboard, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    var disablesInteractiveModalDismiss: Bool {
        get { (objc_getAssociatedObject(self, &GestureNavigationAssociatedKeys.disablesInteractiveModalDismiss) as? Bool) ?? false }
        set { objc_setAssociatedObject(self, &GestureNavigationAssociatedKeys.disablesInteractiveModalDismiss, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    var disablesInteractiveTransitionGestureRecognizerNow: (() -> Bool)? {
        get { objc_getAssociatedObject(self, &GestureNavigationAssociatedKeys.disablesInteractiveTransitionNow) as? (() -> Bool) }
        set { objc_setAssociatedObject(self, &GestureNavigationAssociatedKeys.disablesInteractiveTransitionNow, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC) }
    }

    var interactiveTransitionGestureRecognizerTest: ((CGPoint) -> Bool)? {
        get { objc_getAssociatedObject(self, &GestureNavigationAssociatedKeys.interactiveTransitionTest) as? ((CGPoint) -> Bool) }
        set { objc_setAssociatedObject(self, &GestureNavigationAssociatedKeys.interactiveTransitionTest, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC) }
    }

    var disableAutomaticKeyboardHandling: UIResponderDisableAutomaticKeyboardHandling {
        get {
            let raw = (objc_getAssociatedObject(self, &GestureNavigationAssociatedKeys.disableAutomaticKeyboardHandling) as? Int) ?? 0
            return UIResponderDisableAutomaticKeyboardHandling(rawValue: raw)
        }
        set {
            objc_setAssociatedObject(self, &GestureNavigationAssociatedKeys.disableAutomaticKeyboardHandling, newValue.rawValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
