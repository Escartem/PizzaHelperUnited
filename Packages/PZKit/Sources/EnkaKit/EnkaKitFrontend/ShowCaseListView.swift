// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import Foundation
import PZBaseKit
import SFSafeSymbols
import SwiftUI

// MARK: - ShowCaseListView

@MainActor
public struct ShowCaseListView<P: EKQueriedProfileProtocol, S: Enka.ProfileSummarized<P>>: View {
    // MARK: Lifecycle

    public init(profile: S, expanded: Bool = false) {
        self.profile = profile
        self.expanded = expanded
    }

    // MARK: Public

    @State public var expanded: Bool

    public var body: some View {
        // （Enka 被天空岛服务器喂屎的情形会导致 profile.summarizedAvatars 成为空阵列。）
        if !profile.summarizedAvatars.isEmpty {
            Group {
                if !expanded {
                    bodyAsCardCase
                } else {
                    bodyAsNavList
                }
            }
            #if !os(OSX)
            .fullScreenCover(item: $showingCharacterIdentifier) { enkaId in
                fullScreenCover(selectedAvatarID: enkaId)
            }
            .transaction { transaction in
                transaction.disablesAnimations = !animateOnCallingCharacterShowcase
            }
            #else
            .sheet(isPresented: $isSheetVisible) {
                    if let identifier = showingCharacterIdentifier ?? profile.summarizedAvatars.first?.id {
                        fullScreenCover(selectedAvatarID: identifier)
                            .frame(minWidth: 375, minHeight: 667)
                    } else {
                        EmptyView().onAppear {
                            isSheetVisible = false
                        }
                    }
                }
            #endif
        } else {
            ShowCaseEmptyInfoView(game: profile.game)
        }
    }

    @ViewBuilder public var bodyAsNavList: some View {
        Section {
            ForEach(profile.summarizedAvatars) { avatar in
                NavigationLink {
                    AvatarShowCaseView(
                        selectedAvatarID: avatar.id,
                        profile: profile
                    )
                    .ignoresSafeArea(.all)
                    .environment(\.colorScheme, .dark)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar(.hidden, for: .tabBar)
                    .toolbar(.hidden)
                } label: {
                    makeLabelForNavLink(avatar: avatar)
                }
            }
        }
    }

    /// Deprecated in this view but kept as a reference for future purposes.
    @ViewBuilder public var bodyAsFullScreenCover: some View {
        Section {
            ForEach(profile.summarizedAvatars) { avatar in
                Button {
                    characterButtonDidPress(avatar: avatar)
                } label: {
                    makeLabelForNavLink(avatar: avatar)
                }
                .buttonStyle(.borderless)
            }
        }
    }

    @ViewBuilder public var bodyAsCardCase: some View {
        VStack(alignment: .leading) {
            ScrollView(.horizontal) {
                HStack {
                    ForEach(profile.summarizedAvatars) { avatar in
                        Button {
                            characterButtonDidPress(avatar: avatar)
                        } label: {
                            avatar.asCardIcon(75)
                        }
                    }
                }
            }
            .padding(.vertical, 4)
            HelpTextForScrollingOnDesktopComputer(.horizontal)
        }
    }

    // MARK: Internal

    var subNavTitleText: String {
        "\(profile.nickName) (\(profile.uid))"
    }

    func characterButtonDidPress(avatar: Enka.AvatarSummarized) {
        tapticMedium()
        // TabView 以 EnkaId 为依据。
        showingCharacterIdentifier = avatar.id
        #if os(OSX)
        isSheetVisible.toggle()
        #endif
    }

    @ViewBuilder
    func makeLabelForNavLink(avatar: Enka.AvatarSummarized) -> some View {
        HStack(alignment: .center) {
            let intel = avatar.mainInfo
            let strLevel = "\(intel.terms.levelName): \(intel.avatarLevel)"
            let strEL = "\(intel.terms.constellationName): \(intel.constellation)"
            intel.avatarPhoto(
                size: ceil(Font.baseFontSize * 3),
                circleClipped: true,
                clipToHead: true
            )
            VStack(alignment: .leading) {
                Text(verbatim: intel.name).font(.headline).fontWeight(.bold)
                HStack {
                    Text(verbatim: strLevel)
                    Spacer()
                    Text(verbatim: strEL)
                }
                .monospacedDigit()
                .font(.subheadline)
            }
        }
        .foregroundStyle(.primary)
    }

    @ViewBuilder
    func fullScreenCover(selectedAvatarID: String) -> some View {
        AvatarShowCaseView(
            selectedAvatarID: selectedAvatarID,
            profile: profile
        ) {
            showingCharacterIdentifier = nil
        }
        .transaction { transaction in
            transaction.disablesAnimations = !animateOnCallingCharacterShowcase
        }
        .environment(\.colorScheme, .dark)
    }

    // MARK: Private

    @State private var isSheetVisible = false
    @State private var showingCharacterIdentifier: String?
    @State private var profile: S
    @Environment(\.dismiss) private var dismiss
    @Default(.animateOnCallingCharacterShowcase) private var animateOnCallingCharacterShowcase: Bool

    private func tapticMedium() {
        #if !os(OSX)
        let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
        impactGenerator.prepare()
        impactGenerator.impactOccurred()
        #endif
    }
}

extension EKQueriedProfileProtocol {
    @MainActor
    public func asView(
        theDB: Self.DBType,
        expanded: Bool = false
    )
        -> ShowCaseListView<Self, Enka.ProfileSummarized<Self>> {
        .init(profile: summarize(theDB: theDB), expanded: expanded)
    }
}

#if hasFeature(RetroactiveAttribute)
extension String: @retroactive Identifiable {}
#else
extension String: Identifiable {}
#endif

extension String {
    public var id: String { description }
}

// MARK: - EachAvatarStatView_Previews

#if DEBUG

// swiftlint:disable force_try
// swiftlint:disable force_unwrapping
private let enkaDatabaseHSR = try! Enka.EnkaDB4HSR(locTag: "zh-tw")
private let enkaDatabaseGI = try! Enka.EnkaDB4GI(locTag: "zh-tw")
// swiftlint:enable force_try
// swiftlint:enable force_unwrapping

private let summaryHSR: Enka.QueriedProfileHSR = {
    // swiftlint:disable force_try
    // swiftlint:disable force_unwrapping
    // Note: Do not use #Preview macro. Otherwise, the preview won't be able to access the assets.
    let packageRootPath = URL(fileURLWithPath: #file).pathComponents.prefix(while: { $0 != "Sources" }).joined(
        separator: "/"
    ).dropFirst()
    let testDataPath: String = packageRootPath + "/Tests/EnkaKitTests/TestAssets/"
    let filePath = testDataPath + "testProfileHSR.json"
    let dataURL = URL(fileURLWithPath: filePath)
    return try! Data(contentsOf: dataURL).parseAs(Enka.QueriedResultHSR.self).detailInfo!
    // swiftlint:enable force_try
    // swiftlint:enable force_unwrapping
}()

private let summaryGI: Enka.QueriedProfileGI = {
    // swiftlint:disable force_try
    // swiftlint:disable force_unwrapping
    // Note: Do not use #Preview macro. Otherwise, the preview won't be able to access the assets.
    let packageRootPath = URL(fileURLWithPath: #file).pathComponents.prefix(while: { $0 != "Sources" }).joined(
        separator: "/"
    ).dropFirst()
    let testDataPath: String = packageRootPath + "/Tests/EnkaKitTests/TestAssets/"
    let filePath = testDataPath + "testProfileGI.json"
    let dataURL = URL(fileURLWithPath: filePath)
    return try! Data(contentsOf: dataURL).parseAs(Enka.QueriedResultGI.self).detailInfo!
    // swiftlint:enable force_try
    // swiftlint:enable force_unwrapping
}()

#Preview {
    /// 注意：请仅用 iOS 或者 MacCatalyst 来预览。AppKit 无法正常处理这个 View。
    TabView {
        summaryGI
            .asView(theDB: enkaDatabaseGI, expanded: false).frame(width: 510, height: 720)
            .tabItem { Text(verbatim: "GI") }
        summaryHSR
            .asView(theDB: enkaDatabaseHSR, expanded: false).frame(width: 510, height: 720)
            .tabItem { Text(verbatim: "HSR") }
        summaryGI
            .asView(theDB: enkaDatabaseGI, expanded: true).frame(width: 510, height: 720)
            .tabItem { Text(verbatim: "GIEX") }
        summaryHSR
            .asView(theDB: enkaDatabaseHSR, expanded: true).frame(width: 510, height: 720)
            .tabItem { Text(verbatim: "HSREX") }
    }
    .environment(\.locale, .init(identifier: "zh-Hant-TW"))
}

#endif
