//
// Copyright 2022 Link Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import XCTest
@testable import Signal

class AppDelegateTest: XCTestCase {
    func testApplicationShortcutItems() throws {
        func hasNewMessageShortcut(_ shortcuts: [UIApplicationShortcutItem]) -> Bool {
            shortcuts.contains(where: { $0.type.contains("quickCompose") })
        }

        let unregistered = AppDelegate.applicationShortcutItems(isRegisteredAndReady: false)
        XCTAssertFalse(hasNewMessageShortcut(unregistered))

        let registered = AppDelegate.applicationShortcutItems(isRegisteredAndReady: true)
        XCTAssertTrue(hasNewMessageShortcut(registered))
    }
}
