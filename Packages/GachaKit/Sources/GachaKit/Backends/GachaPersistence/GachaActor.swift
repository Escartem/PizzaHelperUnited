// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@preconcurrency import CoreData
import EnkaKit
import GachaMetaDB
import PZAccountKit
import PZBaseKit
import SwiftData

// MARK: - GachaActor

@ModelActor
public actor GachaActor {
    // MARK: Lifecycle

    public init() {
        self.modelContainer = Self.makeContainer()
        modelExecutor = DefaultSerialModelExecutor(
            modelContext: .init(modelContainer)
        )
    }

    // MARK: Public

    public let cdGachaMOSputnik = try! CDGachaMOSputnik(persistence: .cloud, backgroundContext: true)
}

extension GachaActor {
    @MainActor public static let shared = GachaActor()
    public static let sharedBg = GachaActor()

    public static func makeContainer() -> ModelContainer {
        do {
            return try ModelContainer(
                for: PZGachaEntryMO.self, PZGachaProfileMO.self,
                configurations: Self.modelConfig4Entries, Self.modelConfig4Profiles
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
}

// MARK: - Schemes and Configs.

extension GachaActor {
    public static let schema4Entries = Schema([PZGachaEntryMO.self])
    public static let schema4Profiles = Schema([PZGachaProfileMO.self])

    public static var modelConfig4Entries: ModelConfiguration {
        ModelConfiguration(
            "PZGachaEntryMO",
            schema: Self.schema4Entries,
            isStoredInMemoryOnly: false,
            groupContainer: .none,
            cloudKitDatabase: .private(iCloudContainerName)
        )
    }

    public static var modelConfig4Profiles: ModelConfiguration {
        ModelConfiguration(
            "PZGachaProfileMO",
            schema: schema4Profiles,
            isStoredInMemoryOnly: false,
            groupContainer: .none,
            cloudKitDatabase: .private(iCloudContainerName)
        )
    }
}

// MARK: - CDGachaMO Related Static Methods.

extension GachaActor {
    public static func migrateOldGachasIntoProfiles() async throws {
        try await Self.sharedBg.migrateOldGachasIntoProfiles()
    }

    public func migrateOldGachasIntoProfiles() throws {
        let oldData = try cdGachaMOSputnik.allCDGachaMOAsPZGachaEntryMO()
        try batchInsert(oldData)
    }

    public func batchInsert(_ sources: [PZGachaEntrySendable]) throws {
        let allExistingEntryIDs: [String] = try modelContext.fetch(FetchDescriptor<PZGachaEntryMO>()).map(\.id)
        var profiles: Set<GachaProfileID> = .init()
        sources.forEach { theEntry in
            if !allExistingEntryIDs.contains(theEntry.id) {
                modelContext.insert(theEntry.asMO)
            }
            let profile = GachaProfileID(uid: theEntry.uid, game: theEntry.gameTyped)
            if !profiles.contains(profile) {
                profiles.insert(profile)
            }
        }
        try modelContext.save()
        // try lazyRefreshProfiles(newProfiles: profiles)
        try refreshAllProfiles()
    }

    public func lazyRefreshProfiles(newProfiles: Set<GachaProfileID>? = nil) throws {
        let existingProfiles = try modelContext.fetch(FetchDescriptor<PZGachaProfileMO>())
        var profiles = newProfiles ?? .init()
        existingProfiles.forEach {
            profiles.insert($0.asSendable)
            modelContext.delete($0)
        }
        try modelContext.save()
        let arrProfiles = profiles.sorted { $0.uidWithGame < $1.uidWithGame }
        arrProfiles.forEach { modelContext.insert($0.asMO) }
        try modelContext.save()
    }

    public func refreshAllProfiles() throws {
        let oldProfileMOs = try modelContext.fetch(FetchDescriptor<PZGachaProfileMO>())
        var profiles = oldProfileMOs.map(\.asSendable)
        var entryFetchDescriptor = FetchDescriptor<PZGachaEntryMO>()
        entryFetchDescriptor.propertiesToFetch = [\.uid, \.game]
        let filteredEntries = try modelContext.fetch(entryFetchDescriptor)
        filteredEntries.forEach { currentGachaEntry in
            let alreadyExisted = profiles.first { $0.uidWithGame == currentGachaEntry.uidWithGame }
            guard alreadyExisted == nil else { return }
            let newProfile = GachaProfileID(uid: currentGachaEntry.uid, game: currentGachaEntry.gameTyped)
            profiles.append(newProfile)
        }
        oldProfileMOs.forEach { modelContext.delete($0) }
        try modelContext.save()
        profiles.forEach { modelContext.insert($0.asMO) }
        try modelContext.save()
    }
}
