//
//  TextField.swift
//  Bill Splitter App
//
//  Created by Shofia Ghazali on 15/10/26.
//

import UIKit

extension UIFactory {
    static func createTextField(placeholder: String, keyboardType: UIKeyboardType = .decimalPad) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.keyboardType = keyboardType
        textField.borderStyle = .roundedRect // Gives it a nice standard UIKit border
        textField.clearButtonMode = .whileEditing // Adds the "X" button to clear text quickly
        return textField
    }
}
