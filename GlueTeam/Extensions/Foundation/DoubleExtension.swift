//
//  DoubleExtension.swift
//  GlueTeam
//
//  Created by LIEMNH on 11/10/2023.
//

import Foundation

extension Double {
    func toDate() -> Date? {
        return Date(timeIntervalSince1970: self / 1_000)
    }

    func toString() -> String {
        return "\(self)"
    }

    func toStringWithTwoDigits() -> String {
        return String(format: "%0.2f", self)
    }
}
