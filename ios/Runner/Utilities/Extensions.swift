//
//  Extensions.swift
//  Runner
//
//  Created by Ahnaf Rahat on 16/12/23.
//

import Foundation


extension Date {
    var year: Int {
        let calendar = Calendar.current
        return calendar.component(.year, from: self)
    }

    var month: Int {
        let calendar = Calendar.current
        return calendar.component(.month, from: self)
    }

    var day: Int {
        let calendar = Calendar.current
        return calendar.component(.day, from: self)
    }
}
