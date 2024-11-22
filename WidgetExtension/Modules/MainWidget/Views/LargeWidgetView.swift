// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SFSafeSymbols
import SwiftUI
import WidgetKit

// MARK: - LargeWidgetView

@available(watchOS, unavailable)
struct LargeWidgetView: View {
    let entry: any TimelineEntry
    var dailyNote: any DailyNoteProtocol
    let viewConfig: WidgetViewConfiguration
    let accountName: String?

    var body: some View {
        HStack {
            Spacer()
                .containerRelativeFrame(.horizontal) { length, _ in length / 10 * 1 }
            VStack(alignment: .leading) {
                mainInfo()
                Spacer(minLength: 18)
                DetailInfo(entry: entry, dailyNote: dailyNote, viewConfig: viewConfig, spacing: 17)
            }
            .containerRelativeFrame(.horizontal, alignment: .leading) { length, _ in length / 10 * 4 }
            VStack(alignment: .leading) {
                ExpeditionsView(
                    expeditions: dailyNote.expeditionTasks
                )
                Spacer(minLength: 15)
                if dailyNote.game == .genshinImpact, viewConfig.showMaterialsInLargeSizeWidget {
                    MaterialView()
                }
            }
            .containerRelativeFrame(.horizontal, alignment: .leading) { length, _ in length / 10 * 4 }
            Spacer()
                .containerRelativeFrame(.horizontal) { length, _ in length / 10 * 1 }
        }
        .containerRelativeFrame(.horizontal) { length, _ in length / 10 * 8 }
        .padding()
        .padding(.horizontal)
    }

    @ViewBuilder
    func mainInfo() -> some View {
        VStack(alignment: .leading, spacing: 5) {
            if let accountName = accountName {
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Image(systemSymbol: .personFill)
                    Text(accountName)
                }
                .font(.footnote)
                .foregroundColor(Color("textColor3", bundle: .main))
                .widgetLegibilityShadow()
            }
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                let staminaIconName = switch dailyNote.game {
                case .genshinImpact: "gi_note_resin"
                case .starRail: "hsr_note_trailblazePower"
                case .zenlessZone: "zzz_note_battery"
                }
                Text(verbatim: "\(dailyNote.staminaIntel.finished)")
                    .font(.system(size: 50, design: .rounded))
                    .fontWeight(.medium)
                    .minimumScaleFactor(0.1)
                    .foregroundColor(Color("textColor3", bundle: .main))
                    .widgetLegibilityShadow()
                AccountKit.imageAsset(staminaIconName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 30)
                    .alignmentGuide(.firstTextBaseline) { context in
                        context[.bottom] - 0.17 * context.height
                    }
                    .widgetLegibilityShadow(isText: false)
            }
            HStack {
                Button(intent: WidgetRefreshIntent()) {
                    Image(systemSymbol: .arrowClockwiseCircle)
                        .font(.title3)
                        .foregroundColor(Color("textColor3", bundle: .main))
                        .clipShape(.circle)
                        .widgetLegibilityShadow()
                }
                .buttonStyle(.plain)
                RecoveryTimeText(entry: entry, data: dailyNote)
            }
        }
    }
}
