//
//  BillModel.swift
//  Bill Splitter App
//
//  Created by Shofia Ghazali on 15/10/26.
//

import UIKit

enum RoundingStrategy: String {
    case none = "none"
    case roundUp = "round up"
    case roundToNearestDollar = "nearest dollar"
}

struct BillModel{
    let billAmount: Decimal
    let gstEnabled: Bool
    let serviceEnabled: Bool
    let serviceRate: Decimal
    let gstRate: Decimal
    let partySize: Int
    let roundingStrategy: RoundingStrategy
    
    var serviceChargeAmount: Decimal
    var gstAmount: Decimal
    var totalAmount: Decimal
    var displayTotal: Decimal
    var displayPerPerson: Decimal
    
    init(billAmount: Decimal, gstEnabled: Bool, serviceEnabled: Bool, serviceRate: Decimal, gstRate: Decimal, partySize: Int, roundingStrategy: RoundingStrategy, serviceChargeAmount: Decimal, gstAmount: Decimal, totalAmount: Decimal, displayTotal: Decimal, displayPerPerson: Decimal) {
        
        self.billAmount = billAmount
        self.gstEnabled = gstEnabled
        self.serviceEnabled = serviceEnabled
        self.serviceRate = Decimal(string: String(0.10)) ?? 0.0
        self.gstRate = Decimal(string: String(0.09)) ?? 0.0
        self.partySize = max(partySize, 1)
        self.roundingStrategy = roundingStrategy
        self.serviceChargeAmount = serviceChargeAmount
        self.gstAmount = gstAmount
        self.totalAmount = totalAmount
        self.displayTotal = displayTotal
        self.displayPerPerson = displayPerPerson
        
        self.serviceChargeAmount = serviceEnabled ? (billAmount * serviceRate) : 0
        
        let subtotalWithService = billAmount + self.serviceChargeAmount
        self.gstAmount = gstEnabled ? (subtotalWithService * gstRate) : 0
        
        let rawTotal = subtotalWithService + self.gstAmount
        self.totalAmount = rawTotal
        
        switch roundingStrategy {
        case .none:
          self.displayTotal = rawTotal.rounded(2, rule: .plain)
        case .roundUp:
          self.displayTotal = rawTotal.rounded(0, rule: .up)
        case .roundToNearestDollar:
          self.displayTotal = rawTotal.rounded(0, rule: .plain)
        }

          let rawPerPerson = self.displayTotal / Decimal(self.partySize)
        self.displayPerPerson = rawPerPerson.rounded(2, rule: .plain)

        
    }
}

extension Decimal {
    func rounded(_ scale: Int, rule: NSDecimalNumber.RoundingMode) -> Decimal {
        var value = self
        var result = Decimal()
        NSDecimalRound(&result, &value, scale, rule)
        return result
    }
}
