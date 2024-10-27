// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
// @_exported import PZIntentKit
import SFSafeSymbols
import SwiftUI

@available(watchOS, unavailable)
struct ExpeditionInfoBar: View {
    let dailyNote: any DailyNoteProtocol

    var completionIntel: (ongoing: Int, all: Int) {
        switch dailyNote {
        case let dailyNote as any Note4GI: return dailyNote.expeditionProgressCounts
        case let dailyNote as Note4HSR: return dailyNote.expeditionProgressCounts
        case _ as Note4ZZZ: return (0, 0)
        default: return (0, 0)
        }
    }

    var isExpeditionAllCompleteImage: some View {
        Image(systemSymbol: .figureWalk)
            .overlayImageWithRingProgressBar(
                1,
                scaler: 1,
                offset: (0.3, 0)
            )
    }

    @MainActor var body: some View {
        switch dailyNote {
        case _ as Note4ZZZ: EmptyView() /// ZZZ has no expedition API results.
        default:
            HStack(alignment: .center, spacing: 8) {
                AccountKit.imageAsset("gi_note_expedition")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25)
                    .shadow(color: .white, radius: 1)
                isExpeditionAllCompleteImage
                    .frame(maxWidth: 13, maxHeight: 13)
                    .foregroundColor(Color("textColor3", bundle: .main))
                let completionIntel = completionIntel
                Text(verbatim: "\(completionIntel.ongoing) / \(completionIntel.all)")
                    .lineLimit(1)
                    .foregroundColor(Color("textColor3", bundle: .main))
                    .font(.system(.caption, design: .rounded))
                    .minimumScaleFactor(0.2)
            }
        }
    }
}
