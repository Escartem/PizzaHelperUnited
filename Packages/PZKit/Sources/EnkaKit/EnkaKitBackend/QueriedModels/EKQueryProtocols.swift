// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

// MARK: - EKQueryResultProtocol

public protocol EKQueryResultProtocol: Decodable {
    associatedtype QueriedProfileType: EKQueriedProfileProtocol
    var detailInfo: QueriedProfileType? { get set }
    var uid: String? { get }
    var message: String? { get }
    static var game: Enka.GameType { get }
}

extension EKQueryResultProtocol {
    public typealias DBType = QueriedProfileType.DBType
    public static func queryRAW(uid: String) async throws -> Self {
        try await Enka.Sputnik.fetchEnkaQueryResultRAW(uid, type: Self.self)
    }
}

// MARK: - EKQueriedProfileProtocol

public protocol EKQueriedProfileProtocol {
    associatedtype QueriedAvatar: EKQueriedRawAvatarProtocol
    var avatarDetailList: [QueriedAvatar] { get set }
    var uid: Int { get }
    var locallyCachedData: Self? { get set }
}

extension EKQueriedProfileProtocol {
    public typealias DBType = QueriedAvatar.DBType
    /// 仅制作这个新 API 将旧资料融入新资料，因为反向融合没有任何意义。
    public mutating func merge(old: Self?) -> Self {
        var newResult = self
        old?.avatarDetailList.forEach { oldAvatar in
            let ids = avatarDetailList.map(\.avatarId)
            guard !ids.contains(oldAvatar.avatarId) else { return }
            newResult.avatarDetailList.append(oldAvatar)
        }
        return newResult
    }
}

// MARK: - EKQueriedRawAvatarProtocol

public protocol EKQueriedRawAvatarProtocol: Identifiable {
    associatedtype DBType: EnkaDBProtocol
    var avatarId: Int { get }
    var id: String { get }
    func summarize(theDB: DBType) -> Enka.AvatarSummarized?
}
