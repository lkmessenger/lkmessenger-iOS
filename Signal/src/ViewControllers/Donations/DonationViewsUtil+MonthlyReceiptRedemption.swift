//
// Copyright 2022 Link Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation
import SignalMessaging

extension DonationViewsUtil {
    static func redeemMonthlyReceipts(
        subscriberID: Data,
        newSubscriptionLevel: SubscriptionLevel,
        priorSubscriptionLevel: SubscriptionLevel?
    ) {
        SubscriptionManager.terminateTransactionIfPossible = false

        SubscriptionManager.requestAndRedeemReceiptsIfNecessary(
            for: subscriberID,
            subscriptionLevel: newSubscriptionLevel.level,
            priorSubscriptionLevel: priorSubscriptionLevel?.level
        )
    }
}
