// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import EnkaKit
import Observation
import PZAccountKit
import PZBaseKit
import SFSafeSymbols
import SwiftData
import SwiftUI

// MARK: - DetailPortalTabPage

struct DetailPortalTabPage: View {
    // MARK: Lifecycle

    public init() {}

    // MARK: Internal

    @MainActor var body: some View {
        NavigationStack {
            Form {
                formContent
            }
            .formStyle(.grouped)
            .scrollContentBackground(.hidden)
            .listContainerBackground()
            .refreshable {
                refreshAction()
            }
            .navigationTitle("tab.details.fullTitle".i18nPZHelper)
            .apply(hookNavigationDestinations)
            .apply(hookToolbar)
            .onChange(of: delegate.currentProfile) { oldValue, newValue in
                if oldValue != newValue {
                    Broadcaster.shared.stopRootTabTasks()
                }
            }
            .onAppear {
                if let profile = delegate.currentProfile, !profiles.contains(profile) {
                    delegate.currentProfile = nil
                }
            }
        }
    }

    @ViewBuilder @MainActor var formContent: some View {
        let query4GI = CaseQuerySection(theDB: sharedDB.db4GI, focus: $uidInputFieldFocus)
            .listRowMaterialBackground()
        let query4HSR = CaseQuerySection(theDB: sharedDB.db4HSR, focus: $uidInputFieldFocus)
            .listRowMaterialBackground()
        if let profile = delegate.currentProfile {
            switch profile.game {
            case .genshinImpact:
                ProfileShowCaseSections(theDB: sharedDB.db4GI, pzProfile: profile) {
                    CharInventoryNav(theVM: delegate)
                }
                .listRowMaterialBackground()
                .id(UUID().hashValue) // 很重要，否则在同款游戏之间的帐号切换不会生效。
                .onTapGesture { uidInputFieldFocus = false }
                query4GI
                // Peripheral Nav Sections.
                Section {
                    LedgerNav(theVM: delegate)
                    TravelStatsNav(theVM: delegate)
                }
                .listRowMaterialBackground()
                .onTapGesture { uidInputFieldFocus = false }
            case .starRail:
                ProfileShowCaseSections(theDB: sharedDB.db4HSR, pzProfile: profile) {
                    CharInventoryNav(theVM: delegate)
                }
                .listRowMaterialBackground()
                .id(UUID().hashValue) // 很重要，否则在同款游戏之间的帐号切换不会生效。
                .onTapGesture { uidInputFieldFocus = false }
                query4HSR
            case .zenlessZone: EmptyView()
            }
        } else {
            query4GI
            query4HSR
        }
    }

    @ViewBuilder @MainActor var accountSwitcherMenuLabel: some View {
        LabeledContent {
            let dimension: CGFloat = 30
            Group {
                if let profile: PZProfileMO = delegate.currentProfile {
                    Enka.ProfileIconView(uid: profile.uid, game: profile.game)
                        .frame(width: dimension)
                } else {
                    Image(systemSymbol: .personCircleFill)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: dimension - 8)
                        .foregroundStyle(Color.accentColor)
                }
            }
            .background {
                // Compiler optimization.
                AnyView(erasing: {
                    Circle()
                        .strokeBorder(Color.accentColor, lineWidth: 8)
                        .frame(width: dimension, height: dimension)
                }())
            }
            .frame(width: dimension, height: dimension)
            .clipShape(.circle)
            .compositingGroup()
        } label: {
            if let profile: PZProfileMO = delegate.currentProfile {
                Text(profile.uidWithGame)
            } else {
                Text("dpv.query.menuCommandTitle".i18nPZHelper)
            }
        }
        .padding(4).padding(.leading, 12)
        .blurMaterialBackground()
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    @ViewBuilder
    func accountSwitcherMenu(staticIcon useStaticIcon: Bool = false) -> some View {
        Menu {
            Button {
                withAnimation {
                    delegate.currentProfile = nil
                }
            } label: {
                LabeledContent {
                    Text("dpv.query.menuCommandTitle".i18nPZHelper)
                        .multilineTextAlignment(.leading)
                        .fontWidth(.condensed)
                        .frame(maxWidth: .infinity)
                } label: {
                    Image(systemSymbol: .magnifyingglassCircleFill).frame(width: 48).padding(.trailing, 4)
                }
            }
            Divider()
            ForEach(sortedProfiles) { enumeratedProfile in
                Button {
                    withAnimation {
                        delegate.currentProfile = enumeratedProfile
                    }
                } label: {
                    enumeratedProfile.asMenuLabel4SUI()
                }
            }
        } label: {
            accountSwitcherMenuLabel
        }
    }

    @ViewBuilder @MainActor
    func hookNavigationDestinations(_ content: some View) -> some View {
        content
            .navigationDestination(for: Enka.QueriedProfileGI.self) { result in
                ShowCaseListView(
                    profile: result,
                    enkaDB: sharedDB.db4GI
                )
                .scrollContentBackground(.hidden)
                .listContainerBackground()
            }
            .navigationDestination(for: Enka.QueriedProfileHSR.self) { result in
                ShowCaseListView(
                    profile: result,
                    enkaDB: sharedDB.db4HSR
                )
                .scrollContentBackground(.hidden)
                .listContainerBackground()
            }
    }

    @ViewBuilder @MainActor
    func hookToolbar(_ content: some View) -> some View {
        if !sortedProfiles.isEmpty {
            content.toolbar {
                if delegate.currentProfile != nil {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("", systemImage: "arrow.clockwise") {
                            refreshAction()
                        }
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    accountSwitcherMenu()
                }
            }
        } else {
            content
        }
    }

    // MARK: Private

    @State private var sharedDB: Enka.Sputnik = .shared
    @State private var delegate: DetailPortalViewModel = .init()
    @State private var broadcaster = Broadcaster.shared
    @FocusState private var uidInputFieldFocus: Bool
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PZProfileMO.priority) private var profiles: [PZProfileMO]
    @Default(.queriedEnkaProfiles4GI) private var profiles4GI
    @Default(.queriedEnkaProfiles4HSR) private var profiles4HSR

    private var sortedProfiles: [PZProfileMO] {
        profiles.sorted { $0.priority < $1.priority }
            .filter { $0.game != .zenlessZone } // 临时设定。
    }

    private func refreshAction() {
        broadcaster.refreshPage()
    }
}
