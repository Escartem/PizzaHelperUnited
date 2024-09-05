// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SwiftUI

public struct AbyssReportView4GI: AbyssReportView {
    // MARK: Lifecycle

    public init(data: AbyssReportData) {
        self.data = data
    }

    // MARK: Public

    public typealias AbyssReportData = HoYo.AbyssReport4GI

    public static let navTitle = "hylKit.abyssReportView4GI.navTitle".i18nHYLKit

    public var data: AbyssReportData

    @MainActor public var body: some View {
        debugBody
    }
}
