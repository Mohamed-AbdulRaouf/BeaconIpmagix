//
//  UITextField+.swift
//  BeaconIpmagix_Example
//
//  Created by Raouf on 29/03/2026.
//  Copyright © 2026 CocoaPods. All rights reserved.
//

import UIKit

extension UITextField {

    // Clear button action
    @objc func clearText() {
        self.text = ""
        sendActions(for: .editingChanged)
    }

    // Eye toggle
    @objc func toggleSecureEntry(_ sender: UIButton) {
        sender.isSelected.toggle()
        isSecureTextEntry.toggle()

        // Preserve cursor position after toggling
        if let text = self.text {
            self.text = ""
            self.text = text
        }
    }

    // Focus ring — call in your UIViewController
    func addFocusObservers() {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name.UITextFieldTextDidBeginEditing,
            object: self,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            UIView.animate(withDuration: 0.2) {
                self.layer.borderColor = UIColor(red: 0.27, green: 0.51, blue: 0.98, alpha: 1.0).cgColor
                self.layer.shadowColor = UIColor(red: 0.27, green: 0.51, blue: 0.98, alpha: 0.18).cgColor
                self.layer.shadowOffset = .zero
                self.layer.shadowRadius = 6
                self.layer.shadowOpacity = 1
                self.layer.masksToBounds = false
            }
        }

        NotificationCenter.default.addObserver(
            forName: NSNotification.Name.UITextFieldTextDidEndEditing,
            object: self,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            UIView.animate(withDuration: 0.2) {
                self.layer.borderColor = UIColor(red: 0.88, green: 0.88, blue: 0.93, alpha: 1.0).cgColor
                self.layer.shadowOpacity = 0
                self.layer.masksToBounds = true
            }
        }
    }
}
