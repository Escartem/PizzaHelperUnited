// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZAccountKit
import PZBaseKit
import SwiftUI
import WidgetKit

// MARK: - MainInfoWithDetail

@available(watchOS, unavailable)
struct MainInfoWithDetail: View {
    let entry: any TimelineEntry
    var dailyNote: any DailyNoteProtocol
    let viewConfig: WidgetViewConfiguration
    let accountName: String?

    var body: some View {
        HStack {
            Spacer()
            MainInfo(
                entry: entry,
                dailyNote: dailyNote,
                viewConfig: viewConfig,
                accountName: accountName
            )
            .containerRelativeFrame(.horizontal) { length, _ in length / 9 * 4 }
            Spacer() // Middle Vertical Spacer.
            DetailInfo(
                entry: entry,
                dailyNote: dailyNote,
                viewConfig: viewConfig
            )
            .containerRelativeFrame(.horizontal) { length, _ in length / 9 * 4 }
            Spacer()
        }
        .padding()
    }
}
