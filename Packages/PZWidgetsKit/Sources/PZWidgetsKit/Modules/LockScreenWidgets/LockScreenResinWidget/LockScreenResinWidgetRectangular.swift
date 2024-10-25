// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import PZIntentKit
import SFSafeSymbols
import SwiftUI
import WidgetKit

// MARK: - LockScreenResinWidgetRectangular

struct LockScreenResinWidgetRectangular: View {
    let entry: any TimelineEntry
    @Environment(\.widgetRenderingMode) var widgetRenderingMode

    let result: Result<any DailyNoteProtocol, any Error>

    @MainActor var body: some View {
        switch widgetRenderingMode {
        case .fullColor:
            switch result {
            case let .success(data):
                let staminaIntel = data.staminaIntel
                HStack {
                    VStack(alignment: .leading) {
                        HStack(alignment: .lastTextBaseline, spacing: 2) {
                            let size: CGFloat = 40
                            Text("\(staminaIntel.existing)")
                                .font(.system(size: size, design: .rounded))
                                .minimumScaleFactor(0.5)
                            Text("\(Image("icon.resin"))")
                                .font(.system(size: size * 1 / 2))
                                .minimumScaleFactor(0.5)
                        }
                        .widgetAccentable()
                        .foregroundColor(Color("iconColor.resin.middle"))
                        if staminaIntel.existing >= staminaIntel.max {
                            Text("widget.resin.full")
                                .font(.footnote)
                                .fixedSize(horizontal: false, vertical: true)
                        } else {
                            Text(
                                "infoBlock.refilledAt:\(PZWidgets.dateFormatter.string(from: data.staminaFullTimeOnFinish))"
                            )
                            .lineLimit(2)
                            .font(.footnote)
                            .fixedSize(horizontal: false, vertical: true)
                            .foregroundColor(.gray)
                        }
                    }
                    Spacer()
                }
            case .failure:
                HStack {
                    VStack(alignment: .leading) {
                        HStack(alignment: .lastTextBaseline, spacing: 2) {
                            let size: CGFloat = 40
                            Text(Image(systemSymbol: .ellipsis))
                                .font(.system(size: size, design: .rounded))
                                .minimumScaleFactor(0.5)
                            Text("\(Image("icon.resin"))")
                                .font(.system(size: size * 1 / 2))
                                .minimumScaleFactor(0.5)
                        }
                        .widgetAccentable()
                        .foregroundColor(.cyan)
                        Text(Image("icon.resin"))
                            .font(.footnote)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer()
                }
            }
        default:
            switch result {
            case let .success(data):
                let staminaIntel = data.staminaIntel
                HStack {
                    VStack(alignment: .leading) {
                        HStack(alignment: .lastTextBaseline, spacing: 2) {
                            let size: CGFloat = 40
                            Text("\(staminaIntel.existing)")
                                .font(.system(size: size, design: .rounded))
                                .minimumScaleFactor(0.5)
                            Text("\(Image("icon.resin"))")
                                .font(.system(size: size * 1 / 2))
                                .minimumScaleFactor(0.5)
                        }
                        .foregroundColor(.primary)
                        .widgetAccentable()
                        if staminaIntel.existing >= staminaIntel.max {
                            Text("widget.resin.full")
                                .font(.footnote)
                                .fixedSize(horizontal: false, vertical: true)
                                .foregroundColor(.gray)
                        } else {
                            Text(
                                "infoBlock.refilledAt:\(PZWidgets.dateFormatter.string(from: data.staminaFullTimeOnFinish))"
                            )
                            .lineLimit(2)
                            .font(.footnote)
                            .fixedSize(horizontal: false, vertical: true)
                            .foregroundColor(.gray)
                        }
                    }
                    Spacer()
                }
            case .failure:
                HStack {
                    VStack(alignment: .leading) {
                        HStack(alignment: .lastTextBaseline, spacing: 2) {
                            let size: CGFloat = 40
                            Text(Image(systemSymbol: .ellipsis))
                                .font(.system(size: size, design: .rounded))
                                .minimumScaleFactor(0.5)
                            Text("\(Image("icon.resin"))")
                                .font(.system(size: size * 1 / 2))
                                .minimumScaleFactor(0.5)
                        }
                        .widgetAccentable()
                        Text(Image("icon.resin"))
                            .font(.footnote)
                            .fixedSize(horizontal: false, vertical: true)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
            }
        }
    }
}

// MARK: - FitSystemFont

struct FitSystemFont: ViewModifier {
    var lineLimit: Int
    var minimumScaleFactor: CGFloat
    var percentage: CGFloat

    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .font(.system(size: min(
                    geometry.size.width,
                    geometry.size.height
                ) * percentage))
                .lineLimit(lineLimit)
                .minimumScaleFactor(minimumScaleFactor)
                .position(
                    x: geometry.frame(in: .local).midX,
                    y: geometry.frame(in: .local).midY
                )
        }
    }
}

extension View {
    func fitSystemFont(
        lineLimit: Int = 1,
        minimumScaleFactor: CGFloat = 0.01,
        percentage: CGFloat = 1
    )
        -> ModifiedContent<Self, FitSystemFont> {
        modifier(FitSystemFont(
            lineLimit: lineLimit,
            minimumScaleFactor: minimumScaleFactor,
            percentage: percentage
        ))
    }
}
