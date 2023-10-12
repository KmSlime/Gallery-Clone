//
//  DateExtension.swift
//  GlueTeam
//
//  Created by LIEMNH on 11/10/2023.
//

import Foundation

extension Int64 {
    func convertDate(formate: String = "dd MMM YY, hh:mm a") -> String {
        let date = Date(timeIntervalSince1970: Double(self)/1000)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = formate
        let strDate = dateFormatter.string(from: date)
        return strDate
    }
}

extension Date {
    var month: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM"
        return dateFormatter.string(from: self)
    }

    var year: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY"
        return dateFormatter.string(from: self)
    }

    init(milliseconds: Int) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds / 1000))
    }

    func dateFormatWithSuffix() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd'\(self.daySuffix)', yyyy, h:mm a"
        return dateFormatter.string(from: self)
    }

    var daySuffix: String {
        let calendar = Calendar.current
        let dayOfMonth = calendar.component(.day, from: self)
        switch dayOfMonth {
        case 1, 21, 31: return "st"
        case 2, 22: return "nd"
        case 3, 23: return "rd"
        default: return "th"
        }
    }
}

extension Date {
    func stripTime() -> Date {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: self)
        let date = Calendar.current.date(from: components)
        return date!
    }

    func convertToTimeZone(timeZone: TimeZone? = TimeZone.current, format: String) -> String {
        let formater = DateFormatter()
        formater.timeZone = timeZone
        formater.dateFormat = format
        formater.locale = Locale(identifier: "en_US")
        return formater.string(from: self)
    }
}

extension Date {
    static var currentTimeInterval: Double {
        return Double(Date().timeIntervalSince1970)
    }

    static var currentTimeStamp: Int64 {
        return Int64(Date().timeIntervalSince1970 * 1000)
    }

    func currentYear(_ format: String = "YYYY") -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return Int(dateFormatter.string(from: self)) ?? 0
    }
}
