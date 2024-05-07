import Foundation

/**
 Provides extensions to the Date class for converting dates to strings.
 */
extension Date {
    
    /**
     Converts the date to a string representation.
     - Returns: A string representation of the date in the format "yyyy-MM-dd".
     */
    func toString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }
    
    /**
     Converts the date to a string representation of the time.
     - Returns: A string representation of the time in the format specified by the device's locale settings.
     */
    func toTimeString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
}

/**
 Provides extensions to the String class for converting strings to dates.
 */
extension String {
    
    /**
     Converts the string to a Date object.
     - Returns: A Date object representing the date parsed from the string in the format "yyyy-MM-dd", or nil if the string cannot be parsed.
     */
    func toDate() -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: self)
    }
    
    /**
     Converts the string to a Date object representing the time.
     - Returns: A Date object representing the time parsed from the string, or nil if the string cannot be parsed.
     */
    func toTime() -> Date? {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.date(from: self)
    }
}
