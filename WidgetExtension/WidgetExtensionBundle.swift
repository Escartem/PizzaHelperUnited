// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
@_exported import PZWidgetsKit
import SwiftUI
import WidgetKit

@main
struct WidgetExtensionBundle: WidgetBundle {
    // MARK: Lifecycle

    init() {
        PZProfileActor.attemptToAutoInheritOldAccountsIntoProfiles(resetNotifications: true)
    }

    // MARK: Internal

    var body: some Widget {
        PZWidgets.widgets
    }
}
