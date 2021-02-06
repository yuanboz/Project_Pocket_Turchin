//
//  dateHelper.swift
//  Project_PocketTurchin
//
//  Created by 周元博 on 2/1/21.
//

import Foundation
import UIKit

class dateHelper {
    
    static func dateFormat(startDate: String, endDate: String) -> String {
        let df = DateFormatter()
        df.dateFormat = "dd/MM/yyyy"
        let startDate = df.date(from: startDate)
        let endDate = df.date(from: endDate)
        df.dateFormat = "MMM d, yyyy"
        let strStart = df.string(from: startDate!)
        let strEnd = df.string(from: endDate!)
        return strStart + " - " + strEnd
    }
    
    static func exhibitonType(startDate: String, endDate: String) -> Int {
        let date = Date()
        let df = DateFormatter()
        df.dateFormat = "dd/MM/yyyy"
        let today = df.date(from: df.string(from: date))!
        let start = df.date(from: startDate)!
        let end = df.date(from: endDate)!
        
        if today >= start && today <= end {
            return 1 // "Current exhibition"
        } else if today < start {
            return 2 //"Upcomming exhibition"
        } else {
            return 0 //"Past exhibition"
        }
    }
    
}
