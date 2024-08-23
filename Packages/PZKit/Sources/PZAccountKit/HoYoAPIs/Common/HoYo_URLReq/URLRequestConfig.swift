// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZBaseKit

// MARK: - URLRequestConfig

/// Abstract class storing salt, version, etc for API.
public enum URLRequestConfig {
    public static func getUserAgent(region: HoYo.AccountRegion) -> String {
        """
        Mozilla/5.0 (iPhone; CPU iPhone OS 16_3_1 like Mac OS X) \
        AppleWebKit/605.1.15 (KHTML, like Gecko) miHoYoBBS/\(Self.xRpcAppVersion(region: region))
        """
    }

    public static func genshinLedgerAPIURLHost(region: HoYo.AccountRegion) -> String {
        switch region {
        case .miyoushe: "hk4e-api.mihoyo.com"
        case .hoyoLab: "sg-hk4e-api.hoyolab.com"
        }
    }

    public static func recordURLAPIHost(region: HoYo.AccountRegion) -> String {
        switch region {
        case .miyoushe: "api-takumi-record.mihoyo.com"
        case .hoyoLab: "bbs-api-os.hoyolab.com"
        }
    }

    public static func accountAPIURLHost(region: HoYo.AccountRegion) -> String {
        switch region {
        case .miyoushe: "api-takumi.mihoyo.com"
        case .hoyoLab: "api-account-os.hoyolab.com"
        }
    }

    public static func hostInHeaders(region: HoYo.AccountRegion) -> String {
        switch region {
        case .miyoushe: "https://api-takumi-record.mihoyo.com/"
        case .hoyoLab: "https://bbs-api-os.hoyolab.com/"
        }
    }

    public static func salt(region: HoYo.AccountRegion) -> String {
        switch region {
        case .miyoushe: "xV8v4Qu54lUKrEYFZkJhB8cuOh9Asafs"
        case .hoyoLab: "okr4obncj8bw5a65hbnn5oo6ixjc3l9w"
        }
    }

    public static func domain4PublicOps(region: HoYo.AccountRegion) -> String {
        switch (region, region.game) {
        case (.miyoushe, .genshinImpact): "public-operation-hk4e.mihoyo.com"
        case (.hoyoLab, .genshinImpact): "public-operation-hk4e-sg.hoyoverse.com"
        case (.miyoushe, .starRail): "public-operation-hkrpg.mihoyo.com"
        case (.hoyoLab, .starRail): "public-operation-hkrpg-sg.hoyoverse.com"
        }
    }

    public static func xRpcAppVersion(region: HoYo.AccountRegion) -> String {
        switch region {
        case .miyoushe: "2.74.2"
        case .hoyoLab: "2.59.0"
        }
    }

    public static func xRpcClientType(region: HoYo.AccountRegion) -> String {
        switch region {
        case .miyoushe: "5"
        case .hoyoLab: "2"
        }
    }

    public static func referer(region: HoYo.AccountRegion) -> String {
        switch region {
        case .miyoushe: "https://webstatic.mihoyo.com"
        case .hoyoLab: "https://webstatic-sea.hoyolab.com"
        }
    }

    /// Get unfinished default headers containing host, api-version, etc.
    /// You need to add `DS` field using `URLRequestHelper.getDS` manually
    /// - Parameter region: the region of the account
    /// - Returns: http request headers
    public static func defaultHeaders(
        region: HoYo.AccountRegion,
        additionalHeaders: [String: String]?
    ) async throws
        -> [String: String] {
        var headers = [
            "User-Agent": Self.getUserAgent(region: region),
            "Referer": referer(region: region),
            "Origin": referer(region: region),
            "Accept-Encoding": "gzip, deflate, br",
            "Accept-Language": "zh-CN,zh-Hans;q=0.9",
            "Accept": "application/json, text/plain, */*",
            "Connection": "keep-alive",

            "x-rpc-app_version": xRpcAppVersion(region: region),
            "x-rpc-client_type": xRpcClientType(region: region),
            "x-rpc-page": "3.1.3_#/rpg",
            "x-rpc-device_id": ThisDevice.identifier4Vendor,
            "x-rpc-language": HoYo.APILang.current.rawValue,

            "Sec-Fetch-Dest": "empty",
            "Sec-Fetch-Site": "same-site",
            "Sec-Fetch-Mode": "cors",
        ]
        if let additionalHeaders {
            headers.merge(additionalHeaders, uniquingKeysWith: { $1 })
        }
        return headers
    }
}

extension URLRequestConfig {
    public static func writeXRPCChallengeHeaders4DailyNote(
        to target: inout [String: String],
        for region: HoYo.AccountRegion
    ) {
        guard case .miyoushe = region else { return }
        let header = "https://api-takumi-record.mihoyo.com/game_record/app/"
        switch region.game {
        case .genshinImpact:
            target["x-rpc-challenge_path"] = "\(header)genshin/api/dailyNote"
            target["x-rpc-challenge_game"] = "2"
        case .starRail:
            target["x-rpc-challenge_path"] = "\(header)hkrpg/api/note"
            target["x-rpc-challenge_game"] = "6"
        }
    }
}
