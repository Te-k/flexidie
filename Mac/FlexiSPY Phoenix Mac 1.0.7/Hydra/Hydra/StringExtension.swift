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
    
    func formattedFeatureName() -> String? {
        switch self {
        case "Call":
            return "Call"
        case "SMS":
            return "SMS"
        case "CameraImage":
            return "Image"
        case "Location":
            return "Location"
        case "AddressBook":
            return "Address Book"
        case "Email":
            return "Email"
        case "IMs":
            return "IMs"
        default:
            return nil
        }
    }
    
    func formattedRecordType() -> String? {
        switch self {
        case "Call":
            return "Voice"
        case "SMS":
            return "SMS"
        case "CameraImage":
            return "CameraImageThumbnail"
        case "Location":
            return "Location"
        case "AddressBook":
            return "Address Book"
        case "Email":
            return "Mail"
        case "IMs":
            return "IMs"
        default:
            return nil
        }
    }
    
    var length: Int {
        return self.characters.count
    }
    
    subscript (i: Int) -> String {
        return self[Range(i ..< i + 1)]
    }
    
    func substring(from: Int) -> String {
        return self[Range(min(from, length) ..< length)]
    }
    
    func substring(to: Int) -> String {
        return self[Range(0 ..< max(0, to))]
    }
    
    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return self[Range(start ..< end)]
    }
    
    func firstCharacterInCapital() -> String? {
        return self[0..<1].capitalized
    }
}
