//
//  Label.swift
//  Quiz
//
//  Created by Shofia Ghazali on 15/10/26.
//

import UIKit

extension UIFactory {
    static func createLabel(
        text: String,
        style: UIFont.TextStyle = .body,
        textColor: UIColor = .label,
        alignment: NSTextAlignment = .left
    ) -> UILabel {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: style)
        label.text = text
        label.textColor = textColor // Sets the color
        label.numberOfLines = 0
        label.textAlignment = alignment
        return label
    }
}
