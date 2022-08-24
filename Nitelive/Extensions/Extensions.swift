//
//  Extensions.swift
//  Nitelive
//
//  Created by Sam Santos on 5/4/22.
//

import Foundation

extension Date {
    
    private var shotDateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
        return dateFormatter
    }
    
    func shotDateToString() -> String {
        return shotDateFormatter.string(from: self)
    }
    
    func shotDateFromString(dateString: String) -> Date {
        return shotDateFormatter.date(from: dateString) ?? Date()
    }
    
}
