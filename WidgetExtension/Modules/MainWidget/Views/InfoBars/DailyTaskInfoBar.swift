// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SFSafeSymbols
import SwiftUI

@available(watchOS, unavailable)
struct DailyTaskInfoBar: View {
    let dailyNote: any DailyNoteProtocol

    var assetName: String {
        switch dailyNote.game {
        case .genshinImpact: "gi_note_dailyTask"
        case .starRail: "hsr_note_dailyTask"
        case .zenlessZone: "zzz_note_vitality"
        }
    }

    @ViewBuilder var isTaskRewardReceivedImage: some View {
        if dailyNote.hasDailyTaskIntel {
            let sitrep = dailyNote.dailyTaskCompletionStatus
            Group {
                if sitrep.isAccomplished {
                    if let extraRewardClaimed = dailyNote.claimedRewardsFromKatheryne {
                        Image(systemSymbol: extraRewardClaimed ? .checkmark : .exclamationmark)
                            .overlayImageWithRingProgressBar(1.0, scaler: 0.78)
                    } else {
                        Image(systemSymbol: .checkmark)
                            .overlayImageWithRingProgressBar(1.0, scaler: 0.78)
                    }
                } else {
                    Image(systemSymbol: .ellipsis)
                        .overlayImageWithRingProgressBar(1.0, scaler: 0.78)
                }
            }
        } else {
            EmptyView()
        }
    }

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            AccountKit.imageAsset(assetName)
                .resizable()
                .scaledToFit()
                .frame(width: 25)
                .shadow(color: .white, radius: 1)
                .legibilityShadow(isText: false)
            isTaskRewardReceivedImage
                .frame(maxWidth: 13, maxHeight: 13)
                .foregroundColor(Color("textColor3", bundle: .main))
                .legibilityShadow()

            HStack(alignment: .lastTextBaseline, spacing: 1) {
                Group {
                    let sitrep = dailyNote.dailyTaskCompletionStatus
                    Text(verbatim: "\(sitrep.finished)")
                    Text(verbatim: " / \(sitrep.all)")
                    if sitrep.isAccomplished,
                       let extraRewardClaimed = dailyNote.claimedRewardsFromKatheryne,
                       !extraRewardClaimed {
                        Text("pzWidgetsKit.status.not_received", bundle: .main)
                    }
                }
                .lineLimit(1)
                .foregroundColor(Color("textColor3", bundle: .main))
                .font(.system(.caption, design: .rounded))
                .minimumScaleFactor(0.2)
            }
            .legibilityShadow()
        }
    }
}
