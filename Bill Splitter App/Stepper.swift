//
//  Stepper.swift
//  Bill Splitter App
//
//  Created by Shofia Ghazali on 15/10/26.
//

import UIKit

extension UIFactory {
    static func createStepper(min: Double = 1, max: Double = 100, stepChanged: @escaping (Double) -> Void) -> UIStepper {
        let stepper = UIStepper()
        stepper.minimumValue = min
        stepper.maximumValue = max
        stepper.value = min
        
        // Connect the action callback closure
        let action = UIAction { _ in
            stepChanged(stepper.value)
        }
        stepper.addAction(action, for: .valueChanged)
        
        return stepper
    }
}
