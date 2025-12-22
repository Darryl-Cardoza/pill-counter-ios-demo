//
//  Validation.swift
//  PillCounter
//
//  Created by HC on 03/11/25.
//

import Foundation

struct Validation {
    static func isValidEmail(_ email: String) -> Bool {
        // Regular expression pattern for a valid email
        let pattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: email.utf16.count)
        return regex?.firstMatch(in: email, options: [], range: range) != nil
    }
}
