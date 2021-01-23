//
//  Date+Init.swift
//  DetectItCore
//
//  Created by Илья Харабет on 21.01.2021.
//  Copyright © 2021 Mesterra. All rights reserved.
//

import Foundation

// MARK: - Date parsing

public extension Date {
    
    init?(dateString: String) {
        guard
            let date = Self.availableDateFormats
                .compactMap({ Self.dateFormatter($0).date(from: dateString) })
                .first
        else {
            return nil
        }
        
        self = date
    }
    
    private static let availableDateFormats = [
        "dd.MM.yyyy",
        "MM.dd.yyyy",
        "d.MM.yyyy",
        "dd.M.yyyy",
        "dd.MMM.yyyy",
        "d.MMM.yyyy"
    ]
    
    private static func dateFormatter(_ format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter
    }
    
}

// MARK: - Time parsing

public extension Date {
    
    init?(timeString: String) {
        var foundDate: Date?
        for f in Self.availableTimeFormats {
            if let date = Self.timeFormatter(f).date(from: timeString) {
                foundDate = date
            }
        }
        
        if let foundDate = foundDate {
            self = foundDate
        } else {
            return nil
        }
    }
    
    private static let availableTimeFormats = [
        "HH:mm",
        "H:mm",
        "H:mm:ss",
        "HH:mm:ss",
        "H:mm:s",
        "HH:mm:s",
        "HH:m",
        "H:m",
        "H:m:ss",
        "HH:m:ss",
        "H:m:s",
        "HH:m:s",
        "h:m a",
        "h:mm a",
        "hh:m a",
        "hh:mm a",
        "h:m:s a",
        "h:m:ss a",
        "h:mm:ss a",
        "hh:m:s a",
        "hh:m:ss a",
        "hh:mm:s a",
        "hh:mm:ss a"
    ]
    
    private static func timeFormatter(_ format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter
    }
    
}

// MARK: - Time comparision

public extension Date {
    
    func compareTime(with time: Date) -> Bool {
        let lhsTime = self.time
        let rhsTime = time.time
        
        return lhsTime.h == rhsTime.h
            && lhsTime.m == rhsTime.m
            && lhsTime.s == rhsTime.s
    }
    
    func compareTime(with components: [String]) -> Bool {
        let time = self.time
        let components = components.compactMap { Int($0) }
        
        if let h = time.h, components.item(at: 0) != h {
            return false
        }
        if let m = time.m, components.item(at: 1) != m {
            return false
        }
        if let s = time.s, s != 0, components.item(at: 2) != s {
            return false
        }
        
        return true
    }
    
    private var time: (h: Int?, m: Int?, s: Int?) {
        let components = Calendar.current.dateComponents([.hour, .minute, .second], from: self)
        
        return (components.hour, components.minute, components.second)
    }
    
}

private extension Array {
    
    func item(at index: Int) -> Element? {
        guard (0..<count) ~= index else { return nil }
        return self[index]
    }
    
}
