//
//  ComponentHostView.swift
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

struct GestureDescriptor {
    struct Id: Hashable {
        let id: UInt
    }

    let id: Id
    let create: () -> UIGestureRecognizer
    let update: (UIGestureRecognizer) -> Void

    static func tap(id: UInt = 1, action: @escaping () -> Void) -> GestureDescriptor {
        GestureDescriptor(id: Id(id: id), create: {
            let recognizer = UITapGestureRecognizer()
            recognizer.addAction { action() }
            return recognizer
        }, update: { _ in })
    }
}

private extension UITapGestureRecognizer {
    func addAction(_ action: @escaping () -> Void) {
        let target = TapActionTarget(action)
        objc_setAssociatedObject(self, &TapActionTarget.associationKey, target, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        addTarget(target, action: #selector(TapActionTarget.invoke))
    }
}

private final class TapActionTarget: NSObject {
    static var associationKey: UInt8 = 0
    let action: () -> Void
    init(_ action: @escaping () -> Void) { self.action = action }
    @objc func invoke() { action() }
}

final class GestureAttachableView: UIView {
    private var gestures: [UInt: UIGestureRecognizer] = [:]

    func updateGestures(_ descriptors: [GestureDescriptor]) {
        var valid: [UInt] = []
        for descriptor in descriptors {
            valid.append(descriptor.id.id)
            if let existing = gestures[descriptor.id.id] {
                descriptor.update(existing)
            } else {
                let recognizer = descriptor.create()
                gestures[descriptor.id.id] = recognizer
                isUserInteractionEnabled = true
                addGestureRecognizer(recognizer)
            }
        }
        for id in gestures.keys where !valid.contains(id) {
            if let recognizer = gestures.removeValue(forKey: id) {
                removeGestureRecognizer(recognizer)
            }
        }
    }
}

final class ComponentHostView: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard !isHidden, alpha > 0.01, isUserInteractionEnabled else { return nil }
        for subview in subviews.reversed() {
            let converted = convert(point, to: subview)
            if let hit = subview.hitTest(converted, with: event) {
                return hit
            }
        }
        return nil
    }
}
