//
//  UIButton+.swift
//  BeaconIpmagix_Example
//
//  Created by Raouf on 29/03/2026.
//  Copyright © 2026 CocoaPods. All rights reserved.
//

import UIKit

extension UIButton {
    @objc func didTouchDown() {
        UIView.animate(withDuration: 0.15, delay: 0, options: [.curveEaseInOut, .allowUserInteraction]) {
            self.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
            self.alpha = 0.85
        }
    }

    @objc func didTouchUp() {
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut, .allowUserInteraction]) {
            self.transform = .identity
            self.alpha = 1.0
        }
    }

}
