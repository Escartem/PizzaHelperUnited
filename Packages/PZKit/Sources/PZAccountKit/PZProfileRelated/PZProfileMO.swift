// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit
import SwiftData

// MARK: - PZProfileMO

@Model
public final class PZProfileMO: Codable, ProfileMOProtocol {
    // MARK: Lifecycle

    /// 专门用来从旧版 AccountMO 迁移到全新的 PZProfileMO 帐号体系的建构子。
    /// - Parameters:
    ///   - game: 游戏。
    ///   - uid: UID。
    ///   - configuration: 旧版 AccountMO。
    public init?(game: Pizza.SupportedGame, uid: String, configuration: AccountMOProtocol? = nil) {
        guard let server = HoYo.Server(uid: uid, game: game) else { return nil }
        self.game = game
        self.uid = uid
        self.serverRawValue = server.rawValue
        self.server = server
        if let configuration {
            self.allowNotification = configuration.allowNotification
            self.cookie = configuration.cookie
            self.deviceFingerPrint = configuration.deviceFingerPrint
            self.name = configuration.name
            self.priority = configuration.priority
            self.sTokenV2 = configuration.sTokenV2
            self.uid = configuration.uid
            self.uuid = configuration.uuid
        }
    }

    public init() {}

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.allowNotification = try container.decode(Bool.self, forKey: .allowNotification)
        self.cookie = try container.decode(String.self, forKey: .cookie)
        self.deviceFingerPrint = try container.decode(String.self, forKey: .deviceFingerPrint)
        self.name = try container.decode(String.self, forKey: .name)
        self.priority = try container.decode(Int.self, forKey: .priority)
        self.server = try container.decode(HoYo.Server.self, forKey: .server)
        self.serverRawValue = try container.decode(String.self, forKey: .serverRawValue)
        self.sTokenV2 = try container.decodeIfPresent(String.self, forKey: .sTokenV2)
        self.uid = try container.decode(String.self, forKey: .uid)
        self.uuid = try container.decode(UUID.self, forKey: .uuid)
        self.game = try container.decode(Pizza.SupportedGame.self, forKey: .game)
    }

    // MARK: Public

    public var game: Pizza.SupportedGame = Pizza.SupportedGame.genshinImpact
    public var uid: String = "114514810"
    public var uuid: UUID = UUID()
    public var allowNotification: Bool = true
    public var cookie: String = ""
    public var deviceFingerPrint: String = ""
    public var name: String = ""
    public var priority: Int = 0
    public var server: HoYo.Server = HoYo.Server.celestia(.genshinImpact)
    public var serverRawValue: String = HoYo.Server.celestia(.genshinImpact).rawValue
    public var sTokenV2: String?

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(allowNotification, forKey: .allowNotification)
        try container.encode(cookie, forKey: .cookie)
        try container.encode(deviceFingerPrint, forKey: .deviceFingerPrint)
        try container.encode(name, forKey: .name)
        try container.encode(game, forKey: .game)
        try container.encode(priority, forKey: .priority)
        try container.encode(server, forKey: .server)
        try container.encode(serverRawValue, forKey: .serverRawValue)
        try container.encodeIfPresent(sTokenV2, forKey: .sTokenV2)
        try container.encode(uid, forKey: .uid)
        try container.encode(uuid, forKey: .uuid)
    }

    // MARK: Private

    private enum CodingKeys: CodingKey {
        case allowNotification
        case cookie
        case deviceFingerPrint
        case name
        case game
        case priority
        case serverRawValue
        case server
        case sTokenV2
        case uid
        case uuid
    }
}

extension PZProfileMO {
    public var uidWithGame: String {
        "\(game.uidPrefix)-\(uid)"
    }
}
