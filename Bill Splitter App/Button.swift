//
//  Button.swift
//  Quiz
//
//  Created by Shofia Ghazali on 15/10/26.
//

import UIKit

extension UIFactory {
    static func createButton(
        title: String,
        style: UIFont.TextStyle = .subheadline,
        backgroundColor: UIColor? = nil, // 1. Add background color parameter
        foregroundColor: UIColor = .white // Text color
    ) -> UIButton {
        
        // 2. Use a filled configuration if a background color is provided
        var config = backgroundColor != nil ? UIButton.Configuration.filled() : UIButton.Configuration.plain()
        
        config.title = title
        config.baseBackgroundColor = backgroundColor
        config.baseForegroundColor = foregroundColor
        config.cornerStyle = .medium // Gives it rounded corners automatically
        
        let button = UIButton(configuration: config, primaryAction: nil)
        button.titleLabel?.font = .preferredFont(forTextStyle: style)
        
        return button
    }
}
