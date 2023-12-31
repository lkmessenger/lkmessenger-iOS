//
// Copyright 2018 Link Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

#import "MockEnvironment.h"
#import <SignalServiceKit/MockSSKEnvironment.h>
#import <XCTest/XCTest.h>

NS_ASSUME_NONNULL_BEGIN

@class SDSAnyReadTransaction;
@class SDSAnyWriteTransaction;

@interface SignalBaseTest : XCTestCase

- (void)readWithBlock:(void (^)(SDSAnyReadTransaction *transaction))block;
- (void)writeWithBlock:(void (^)(SDSAnyWriteTransaction *transaction))block;

@end

NS_ASSUME_NONNULL_END
