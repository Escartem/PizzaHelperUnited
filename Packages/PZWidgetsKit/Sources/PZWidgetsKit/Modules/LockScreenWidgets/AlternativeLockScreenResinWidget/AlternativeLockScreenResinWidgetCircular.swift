// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import PZIntentKit
import SFSafeSymbols
import SwiftUI
import WidgetKit

struct AlternativeLockScreenResinWidgetCircular: View {
    let entry: any TimelineEntry
    @Environment(\.widgetRenderingMode) var widgetRenderingMode

    let result: Result<any DailyNoteProtocol, any Error>

    @MainActor var body: some View {
        VStack(spacing: 0) {
            let img = Image("icon.resin")
                .resizable()
                .scaledToFit()
            switch widgetRenderingMode {
            case .fullColor:
                LinearGradient(
                    colors: [
                        .init("iconColor.resin.dark"),
                        .init("iconColor.resin.middle"),
                        .init("iconColor.resin.light"),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .mask(img)
            default:
                img
            }
            // ------------
            switch result {
            case let .success(data):
                switch data {
                case let data as any Note4GI:
                    Text("\(data.resinInfo.currentResinDynamic)")
                        .font(.system(.body, design: .rounded).weight(.medium))
                        .minimumScaleFactor(0.1)
                default:
                    Image(systemSymbol: .ellipsis)
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
