//
//  Date+formatter.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 3/16/26.
//

import Foundation

extension Date {
    var shortFormatted: String {
        self.formatted(.dateTime.month(.twoDigits).day(.twoDigits).year(.twoDigits))
    }

    var monthDay: String {
        self.formatted(.dateTime.month(.abbreviated).day())
    }
}
