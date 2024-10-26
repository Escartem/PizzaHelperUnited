// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
@_exported import PZIntentKit
import SFSafeSymbols
import SwiftUI
import WidgetKit

// MARK: - LargeWidgetView

struct LargeWidgetView: View {
    let entry: any TimelineEntry
    var dailyNote: any DailyNoteProtocol
    let viewConfig: WidgetViewConfiguration
    let accountName: String?

    @MainActor var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                VStack(alignment: .leading) {
                    mainInfo()
                    Spacer(minLength: 18)
                    DetailInfo(entry: entry, dailyNote: dailyNote, viewConfig: viewConfig, spacing: 17)
                }

                Spacer(minLength: 30)
                switch dailyNote {
                case let dailyNote as any Note4GI:
                    VStack(alignment: .leading) {
                        ExpeditionsView(
                            expeditions: dailyNote.expeditions.expeditions
                        )
                        if viewConfig.showMaterialsInLargeSizeWidget {
                            Spacer(minLength: 15)
                            MaterialView()
                        }
                    }
                    .frame(maxWidth: UIScreen.main.bounds.width / 8 * 3)
                case let dailyNote as Note4HSR:
                    VStack(alignment: .leading) {
                        ExpeditionsView(
                            expeditions: dailyNote.assignmentInfo.assignments
                        )
                        if viewConfig.showMaterialsInLargeSizeWidget {
                            Spacer(minLength: 15)
                            MaterialView()
                        }
                    }
                    .frame(maxWidth: UIScreen.main.bounds.width / 8 * 3)
                case let dailyNote as Note4ZZZ:
                    EmptyView()
                default: EmptyView()
                }
                Spacer()
            }
            Spacer()
        }
        .padding()
    }

    @MainActor @ViewBuilder
    func mainInfo() -> some View {
        VStack(alignment: .leading, spacing: 5) {
//            Spacer()
            if let accountName = accountName {
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Image(systemSymbol: .personFill)
                    Text(accountName)
                }
                .font(.footnote)
                .foregroundColor(Color("textColor3"))
            }
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                switch dailyNote {
                case let dailyNote as any Note4GI:
                    Text("\(dailyNote.resinInfo.currentResinDynamic)")
                        .font(.system(size: 50, design: .rounded))
                        .fontWeight(.medium)
                        .minimumScaleFactor(0.1)
                        .foregroundColor(Color("textColor3"))
                        .shadow(radius: 1)
                    Image("树脂")
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 30)
                        .alignmentGuide(.firstTextBaseline) { context in
                            context[.bottom] - 0.17 * context.height
                        }
                        .shadow(radius: 0.8)
                case let dailyNote as Note4HSR:
                    Text("\(dailyNote.staminaInfo.currentStamina)")
                        .font(.system(size: 50, design: .rounded))
                        .fontWeight(.medium)
                        .minimumScaleFactor(0.1)
                        .foregroundColor(Color("textColor3"))
                        .shadow(radius: 1)
                    Image("开拓力")
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 30)
                        .alignmentGuide(.firstTextBaseline) { context in
                            context[.bottom] - 0.17 * context.height
                        }
                        .shadow(radius: 0.8)
                case let dailyNote as Note4ZZZ:
                    Text("\(dailyNote.energy.currentEnergyAmountDynamic)")
                        .font(.system(size: 50, design: .rounded))
                        .fontWeight(.medium)
                        .minimumScaleFactor(0.1)
                        .foregroundColor(Color("textColor3"))
                        .shadow(radius: 1)
                    Image("绝区电量")
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 30)
                        .alignmentGuide(.firstTextBaseline) { context in
                            context[.bottom] - 0.17 * context.height
                        }
                        .shadow(radius: 0.8)
                default: EmptyView()
                }
            }
            HStack {
                Image("hourglass.circle")
                    .foregroundColor(Color("textColor3"))
                    .font(.title3)
                RecoveryTimeText(entry: entry, data: dailyNote)
            }
        }
    }
}
