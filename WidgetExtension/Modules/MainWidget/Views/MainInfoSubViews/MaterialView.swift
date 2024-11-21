// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import GITodayMaterialsKit
import SwiftUI

@available(watchOS, unavailable)
struct MaterialView: View {
    // MARK: Lifecycle

    init(alternativeLayout: Bool = false, today: MaterialWeekday? = nil) {
        self.alternativeLayout = alternativeLayout
        self.today = today ?? .today()
    }

    // MARK: Internal

    let alternativeLayout: Bool
    var today: MaterialWeekday? = .today()

    var talentMaterialProvider: TalentMaterialProvider { .init(weekday: today) }
    var weaponMaterialProvider: WeaponMaterialProvider { .init(weekday: today) }

    var body: some View {
        if today != nil {
            if alternativeLayout {
                GeometryReader { g in
                    ZStack {
                        HStack(spacing: g.size.height * 0.3) {
                            ForEach(
                                weaponMaterialProvider.todaysMaterials,
                                id: \.nameTag
                            ) { material in
                                material.iconObj
                                    .resizable()
                                    .scaledToFit()
                            }
                        }
                        .padding([.trailing, .bottom], g.size.height * 0.2)
                        HStack(spacing: g.size.height * 0.3) {
                            ForEach(
                                talentMaterialProvider.todaysMaterials,
                                id: \.nameTag
                            ) { material in
                                material.iconObj
                                    .resizable()
                                    .scaledToFit()
                            }
                        }
                        .padding([.top], g.size.height * 0.2)
                        .padding([.leading], g.size.height * 0.7)
                    }
                    .widgetLegibilityShadow(isText: false)
                }
            } else {
                VStack {
                    HStack(spacing: -5) {
                        ForEach(
                            weaponMaterialProvider.todaysMaterials,
                            id: \.nameTag
                        ) { material in
                            material.iconObj
                                .resizable()
                                .scaledToFit()
                        }
                    }
                    HStack(spacing: -5) {
                        ForEach(
                            talentMaterialProvider.todaysMaterials,
                            id: \.nameTag
                        ) { material in
                            material.iconObj
                                .resizable()
                                .scaledToFit()
                        }
                    }
                }
                .widgetLegibilityShadow(isText: false)
            }
        } else {
            Text("pzWidgetsKit.material.sunday", bundle: .main)
                .foregroundColor(Color("textColor3", bundle: .main))
                .font(.caption)
                .lineLimit(1)
                .minimumScaleFactor(0.2)
                .widgetLegibilityShadow()
        }
    }
}
