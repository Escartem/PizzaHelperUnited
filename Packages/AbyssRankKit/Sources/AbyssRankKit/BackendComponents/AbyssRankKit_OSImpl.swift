// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation

extension String {
    public var i18nAbyssRank: String {
        String(localized: .init(stringLiteral: self), bundle: .module)
    }
}

extension String.LocalizationValue {
    public var i18nAbyssRank: String {
        String(localized: self, bundle: .module)
    }
}

extension Date {
    func yyyyMM() -> Int {
        let formatter = DateFormatter.Gregorian()
        formatter.dateFormat = "yyyyMM"
        return Int(formatter.string(from: self))!
    }
}
