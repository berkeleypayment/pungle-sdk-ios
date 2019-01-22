/*
 * Copyright (C) 2019 Pungle Canada Inc - All Rights Reserved
 */

import Foundation

extension Date {
    
    func getYear() -> Int{
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY"
        let dateStr = dateFormatter.string(from: now)
        
        return Int(dateStr) ?? 0
    }
    
}
