// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation

extension HoYo {
    /// Get `MultiToken` by using a login ticket
    ///
    /// - Parameters:
    ///     - loginTicket: Login ticket string to use when making the API request
    ///     - loginUid: Login user ID string
    /// - Returns: A `MultiToken` struct
    public static func getMultiTokenByLoginTicket(
        region: HoYo.AccountRegion,
        loginTicket: String,
        loginUid: String
    ) async throws
        -> MultiToken {
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "login_ticket", value: loginTicket),
            URLQueryItem(name: "token_types", value: "3"),
            URLQueryItem(name: "uid", value: loginUid),
        ]

        let request = try await Self.generateAccountAPIRequest(
            region: region, // 此处可以乱填游戏名称，因为不影响。
            path: "/auth/api/getMultiTokenByLoginTicket",
            queryItems: queryItems,
            cookie: nil
        )

        let (data, _) = try await URLSession.shared.data(for: request)

        return try .decodeFromMiHoYoAPIJSONResult(data: data)
    }
}
