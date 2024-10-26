// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
@_exported import PZIntentKit
import SFSafeSymbols
import SwiftUI
import WidgetKit

struct HomeCoinInfoBar: View {
    let entry: any TimelineEntry
    let homeCoinInfo: GeneralNote4GI.HomeCoinInfo4GI

    var isHomeCoinFullImage: some View {
        (homeCoinInfo.currentHomeCoinDynamic == homeCoinInfo.maxHomeCoin)
            ? Image(systemSymbol: .exclamationmark)
            .overlayImageWithRingProgressBar(
                Double(homeCoinInfo.currentHomeCoinDynamic) / Double(homeCoinInfo.maxHomeCoin),
                scaler: 0.78
            )
            : Image(systemSymbol: .leafFill)
            .overlayImageWithRingProgressBar(
                Double(homeCoinInfo.currentHomeCoinDynamic) /
                    Double(homeCoinInfo.maxHomeCoin)
            )
    }

    @MainActor var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Image("洞天宝钱")
                .resizable()
                .scaledToFit()
                .frame(width: 25)
                .shadow(color: .white, radius: 1)
            isHomeCoinFullImage
                .frame(maxWidth: 13, maxHeight: 13)
                .foregroundColor(Color("textColor3"))
            HStack(alignment: .lastTextBaseline, spacing: 1) {
                Text("\(homeCoinInfo.currentHomeCoinDynamic)")
                    .lineLimit(1)
                    .foregroundColor(Color("textColor3"))
                    .font(.system(.body, design: .rounded))
                    .minimumScaleFactor(0.2)
            }
        }
    }
}
