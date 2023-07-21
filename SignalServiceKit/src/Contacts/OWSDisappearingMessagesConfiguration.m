//
// Copyright 2017 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

#import "OWSDisappearingMessagesConfiguration.h"
#import <SignalCoreKit/NSDate+OWS.h>
#import <SignalCoreKit/NSString+OWS.h>
#import <SignalServiceKit/SignalServiceKit-Swift.h>

NS_ASSUME_NONNULL_BEGIN

static NSString *const kUniversalTimerThreadId = @"kUniversalTimerThreadId";

@interface OWSDisappearingMessagesConfiguration ()

@property (nonatomic, getter=isEnabled) BOOL enabled;
@property (nonatomic) uint32_t durationSeconds;

@end

#pragma mark -

@implementation OWSDisappearingMessagesConfiguration

- (nullable instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];

    return self;
}

- (instancetype)initWithThreadId:(NSString *)threadId enabled:(BOOL)isEnabled durationSeconds:(uint32_t)seconds
{
    OWSAssertDebug(threadId.length > 0);

    // Thread id == configuration id.
    self = [super initWithUniqueId:threadId];
    if (!self) {
        return self;
    }

    _enabled = isEnabled;
    _durationSeconds = seconds;

    return self;
}

// --- CODE GENERATION MARKER

// This snippet is generated by /Scripts/sds_codegen/sds_generate.py. Do not manually edit it, instead run `sds_codegen.sh`.

// clang-format off

- (instancetype)initWithGrdbId:(int64_t)grdbId
                      uniqueId:(NSString *)uniqueId
                 durationSeconds:(unsigned int)durationSeconds
                         enabled:(BOOL)enabled
{
    self = [super initWithGrdbId:grdbId
                        uniqueId:uniqueId];

    if (!self) {
        return self;
    }

    _durationSeconds = durationSeconds;
    _enabled = enabled;

    return self;
}

// clang-format on

// --- CODE GENERATION MARKER

- (BOOL)isUrgent
{
    return NO;
}

+ (nullable instancetype)fetchWithThread:(TSThread *)thread transaction:(SDSAnyReadTransaction *)transaction
{
    return [self fetchWithThreadId:thread.uniqueId transaction:transaction];
}

+ (instancetype)fetchOrBuildDefaultWithThread:(TSThread *)thread transaction:(SDSAnyReadTransaction *)transaction
{
    return [self fetchOrBuildDefaultWithThreadId:thread.uniqueId transaction:transaction];
}

+ (nullable instancetype)fetchWithThreadId:(NSString *)threadId transaction:(SDSAnyReadTransaction *)transaction
{
    // Thread id == configuration id.
    return [self anyFetchWithUniqueId:threadId transaction:transaction];
}

+ (instancetype)fetchOrBuildDefaultWithThreadId:(NSString *)threadId transaction:(SDSAnyReadTransaction *)transaction
{
    OWSDisappearingMessagesConfiguration *_Nullable configuration = [self fetchWithThreadId:threadId
                                                                                transaction:transaction];
    if (configuration != nil) {
        return configuration;
    }

    return [[self alloc] initWithThreadId:threadId
                                  enabled:OWSDisappearingMessagesConfigurationDefaultExpirationDuration > 0
                          durationSeconds:OWSDisappearingMessagesConfigurationDefaultExpirationDuration];
}

+ (instancetype)fetchOrBuildDefaultUniversalConfigurationWithTransaction:(SDSAnyReadTransaction *)transaction
{
    return [self fetchOrBuildDefaultWithThreadId:kUniversalTimerThreadId transaction:transaction];
}

+ (NSArray<NSNumber *> *)presetDurationsSeconds
{
    return @[
        @(30 * kSecondInterval),
        @(5 * kMinuteInterval),
        @(1 * kHourInterval),
        @(8 * kHourInterval),
        @(24 * kHourInterval),
        @(1 * kWeekInterval),
        @(4 * kWeekInterval)
    ];
}

+ (uint32_t)maxDurationSeconds
{
    return (uint32_t)kYearInterval;
}

- (NSString *)durationString
{
    return [NSString formatDurationLosslessWithDurationSeconds:self.durationSeconds];
}

- (BOOL)hasChangedWithTransaction:(SDSAnyReadTransaction *)transaction
{
    OWSAssertDebug(transaction != nil);

    // Thread id == configuration id.
    OWSDisappearingMessagesConfiguration *oldConfiguration =
        [OWSDisappearingMessagesConfiguration fetchOrBuildDefaultWithThreadId:self.uniqueId transaction:transaction];

    return (self.isEnabled != oldConfiguration.isEnabled || self.durationSeconds != oldConfiguration.durationSeconds);
}

- (instancetype)copyWithIsEnabled:(BOOL)isEnabled
{
    OWSDisappearingMessagesConfiguration *newInstance = [self copy];
    newInstance.enabled = isEnabled;
    return newInstance;
}

- (instancetype)copyWithDurationSeconds:(uint32_t)durationSeconds
{
    OWSDisappearingMessagesConfiguration *newInstance = [self copy];
    newInstance.durationSeconds = durationSeconds;
    return newInstance;
}

- (instancetype)copyAsEnabledWithDurationSeconds:(uint32_t)durationSeconds
{
    OWSDisappearingMessagesConfiguration *newInstance = [self copy];
    newInstance.enabled = YES;
    newInstance.durationSeconds = durationSeconds;
    return newInstance;
}

- (BOOL)isEqual:(id)other
{
    if (![other isKindOfClass:[OWSDisappearingMessagesConfiguration class]]) {
        return NO;
    }

    OWSDisappearingMessagesConfiguration *otherConfiguration = (OWSDisappearingMessagesConfiguration *)other;
    if (otherConfiguration.isEnabled != self.isEnabled) {
        return NO;
    }
    if (!self.isEnabled) {
        // Don't bother comparing durationSeconds if not enabled.
        return YES;
    }
    return otherConfiguration.durationSeconds == self.durationSeconds;
}

@end

NS_ASSUME_NONNULL_END
