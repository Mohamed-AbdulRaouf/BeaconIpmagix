//
//  UILabel+.swift
//  BeaconIpmagix_Example
//
//  Created by Raouf on 29/03/2026.
//  Copyright © 2026 CocoaPods. All rights reserved.
//

import UIKit

extension UILabel {
    func addCharacterSpacing(kernValue: CGFloat) {
        guard let text = self.text, !text.isEmpty else { return }
        let attributed = NSMutableAttributedString(string: text)
        attributed.addAttribute(.kern, value: kernValue, range: NSRange(location: 0, length: attributed.length - 1))
        self.attributedText = attributed
    }
}
