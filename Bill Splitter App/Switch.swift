//
//  Switch.swift
//  Quiz
//
//  Created by Shofia Ghazali on 15/10/26.
//

import UIKit

extension UIFactory {
    static func createSwitch() -> UISwitch {
        let toggle = UISwitch()
        toggle.isOn = false
        toggle.onTintColor = .systemGreen
        toggle.thumbTintColor = .white
        return toggle
    }
}

