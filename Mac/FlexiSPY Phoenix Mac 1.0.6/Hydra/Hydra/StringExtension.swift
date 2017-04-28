//
//  StringExtension.swift
//  Hydra
//
//  Created by Chanin Nokpet on 12/15/16.
//  Copyright © 2016 Makara Khloth. All rights reserved.
//

import Foundation

enum HydraDateFormat {
    case dateWithSlash
    case dateWithFullName
    case dateTimeSMSCell
    case time
}

extension String {
    func formattedDateTimeString(toFormat:HydraDateFormat) -> String? {
        let dateFormatterBefore = DateFormatter()
        dateFormatterBefore.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        guard let unformattedDate = dateFormatterBefore.date(from: self) else {
            return nil
        }
        
        let dateFormatterAfter = DateFormatter()
        switch toFormat {
        case .dateWithSlash:
            dateFormatterAfter.dateFormat = "dd/MM/yyyy"
        case .dateWithFullName:
            dateFormatterAfter.dateFormat = "MMMM d, yyyy"
        case .dateTimeSMSCell:
            dateFormatterAfter.dateFormat = "E, MMM d, HH:mm"
        case .time:
            dateFormatterAfter.dateFormat = "HH:mm"
        }

        return dateFormatterAfter.string(from: unformattedDate)
    }
    
    func formattedCallDirection() -> String? {
        switch self {
        case "In":
            return "Incoming Call"
        case "Out":
            return "Outgoing Call"
        case "MissedCall":
            return "Missed Call"
        default:
            return nil
        }
    }
}
