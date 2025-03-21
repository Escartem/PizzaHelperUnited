// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SFSafeSymbols
import SwiftUI
import WidgetKit

@available(macOS, unavailable)
struct LockScreenHomeCoinWidgetCircular: View {
    let entry: any TimelineEntry
    @Environment(\.widgetRenderingMode) var widgetRenderingMode

    let result: Result<any DailyNoteProtocol, any Error>

    var body: some View {
        VStack(spacing: 0) {
            Pizza.SupportedGame.genshinImpact.giRealmCurrencyAssetSVG
                .resizable()
                .scaledToFit()
                .apply { imageView in
                    if widgetRenderingMode == .fullColor {
                        imageView
                            .foregroundColor(Color("iconColor.homeCoin.lightBlue", bundle: .main))
                    } else {
                        imageView
                    }
                }
            switch result {
            case let .success(data):
                switch data {
                case let data as any Note4GI:
                    Text(verbatim: "\(data.homeCoinInfo.currentHomeCoin)")
                        .font(.system(.body, design: .rounded).weight(.medium))
                default:
                    Text(verbatim: "WRONG\nGAME")
                        .fontWidth(.compressed)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.2)
                }
            case .failure:
                Image(systemSymbol: .ellipsis)
            }
        }
        .widgetAccentable(widgetRenderingMode == .accented)
        #if os(watchOS)
            .padding(.vertical, 2)
            .padding(.top, 1)
        #else
            .padding(.vertical, 2)
        #endif
    }
}
