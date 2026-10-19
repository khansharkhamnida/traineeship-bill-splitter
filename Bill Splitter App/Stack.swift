//
//  Stack.swift
//  Quiz
//
//  Created by Shofia Ghazali on 15/10/26.
//

import UIKit

extension UIFactory {
    static func createHorizontalRow(views: [UIView]) -> UIStackView {
        let row = UIStackView(arrangedSubviews: views)
        row.axis = .horizontal
        row.distribution = .equalSpacing
        row.alignment = .center
        return row
    }
}

