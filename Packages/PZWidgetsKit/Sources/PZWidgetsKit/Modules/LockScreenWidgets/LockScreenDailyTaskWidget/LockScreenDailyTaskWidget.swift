// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import PZIntentKit
import SwiftUI
import WidgetKit

// MARK: - LockScreenDailyTaskWidget

struct LockScreenDailyTaskWidget: Widget {
    let kind: String = "LockScreenDailyTaskWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: SelectOnlyAccountIntent.self,
            provider: LockScreenWidgetProvider(recommendationsTag: "watch.info.dailyCommission")
        ) { entry in
            LockScreenDailyTaskWidgetView(entry: entry)
                .lockscreenContainerBackground { EmptyView() }
        }
        .configurationDisplayName("app.dailynote.card.dailyTask.label")
        .description("widget.intro.dailyCommission")
        #if os(watchOS)
            .supportedFamilies([.accessoryCircular, .accessoryCorner])
        #else
            .supportedFamilies([.accessoryCircular])
        #endif
    }
}

// MARK: - LockScreenDailyTaskWidgetView

struct LockScreenDailyTaskWidgetView: View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    let entry: LockScreenWidgetProvider.Entry
    @MainActor var body: some View {
        Group {
            switch family {
            #if os(watchOS)
            case .accessoryCorner:
                LockScreenDailyTaskWidgetCorner(result: result)
            #endif
            case .accessoryCircular:
                LockScreenDailyTaskWidgetCircular(result: result)
            default:
                EmptyView()
            }
        }
        .widgetURL(url)
    }

    var result: Result<any DailyNoteProtocol, any Error> { entry.result }
    var accountName: String? { entry.accountName }

    var url: URL? {
        let errorURL: URL = {
            var components = URLComponents()
            components.scheme = "ophelperwidget"
            components.host = "accountSetting"
            components.queryItems = [
                .init(
                    name: "accountUUIDString",
                    value: entry.accountUUIDString
                ),
            ]
            return components.url!
        }()

        switch result {
        case .success:
            return nil
        case .failure:
            return errorURL
        }
    }
}
