//
//  GestureUtilities.swift
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

import UIKit

func doesViewTreeDisableInteractiveTransitionGestureRecognizer(_ view: UIView, keyboardOnly: Bool = false) -> Bool {
    if view.disablesInteractiveTransitionGestureRecognizer && !keyboardOnly {
        return true
    }
    if view.disablesInteractiveKeyboardGestureRecognizer {
        return true
    }
    if let f = view.disablesInteractiveTransitionGestureRecognizerNow, f() {
        return true
    }
    if let superview = view.superview {
        return doesViewTreeDisableInteractiveTransitionGestureRecognizer(superview, keyboardOnly: keyboardOnly)
    }
    return false
}

func cancelParentGestures(view: UIView, ignore: [UIGestureRecognizer] = []) {
    if let gestureRecognizers = view.gestureRecognizers {
        for recognizer in gestureRecognizers {
            if ignore.contains(where: { $0 === recognizer }) {
                continue
            }
            recognizer.state = .failed
        }
    }
    if let superview = view.superview {
        cancelParentGestures(view: superview, ignore: ignore)
    }
}

func viewTreeContainsFirstResponder(view: UIView) -> Bool {
    if view.isFirstResponder {
        return true
    }
    for subview in view.subviews {
        if viewTreeContainsFirstResponder(view: subview) {
            return true
        }
    }
    return false
}

extension UIView {
    func findFirstResponder() -> UIView? {
        if isFirstResponder {
            return self
        }
        for subview in subviews {
            if let found = subview.findFirstResponder() {
                return found
            }
        }
        return nil
    }
}
