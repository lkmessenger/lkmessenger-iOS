//
// Copyright 2020 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

#import "IncomingGroupsV2MessageJob.h"
#import <SignalServiceKit/SignalServiceKit-Swift.h>

NS_ASSUME_NONNULL_BEGIN

@implementation IncomingGroupsV2MessageJob

+ (NSString *)collection
{
    return @"IncomingGroupsV2MessageJob";
}

- (instancetype)initWithEnvelopeData:(NSData *)envelopeData
                       plaintextData:(NSData *_Nullable)plaintextData
                             groupId:(NSData *_Nullable)groupId
                     wasReceivedByUD:(BOOL)wasReceivedByUD
             serverDeliveryTimestamp:(uint64_t)serverDeliveryTimestamp
{
    OWSAssertDebug(envelopeData);

    self = [super init];
    if (!self) {
        return self;
    }

    _envelopeData = envelopeData;
    _plaintextData = plaintextData;
    _groupId = groupId;
    _wasReceivedByUD = wasReceivedByUD;
    _serverDeliveryTimestamp = serverDeliveryTimestamp;
    _createdAt = [NSDate new];

    return self;
}

// --- CODE GENERATION MARKER

// This snippet is generated by /Scripts/sds_codegen/sds_generate.py. Do not manually edit it, instead run `sds_codegen.sh`.

// clang-format off

- (instancetype)initWithGrdbId:(int64_t)grdbId
                      uniqueId:(NSString *)uniqueId
                       createdAt:(NSDate *)createdAt
                    envelopeData:(NSData *)envelopeData
                         groupId:(nullable NSData *)groupId
                   plaintextData:(nullable NSData *)plaintextData
         serverDeliveryTimestamp:(uint64_t)serverDeliveryTimestamp
                 wasReceivedByUD:(BOOL)wasReceivedByUD
{
    self = [super initWithGrdbId:grdbId
                        uniqueId:uniqueId];

    if (!self) {
        return self;
    }

    _createdAt = createdAt;
    _envelopeData = envelopeData;
    _groupId = groupId;
    _plaintextData = plaintextData;
    _serverDeliveryTimestamp = serverDeliveryTimestamp;
    _wasReceivedByUD = wasReceivedByUD;

    return self;
}

// clang-format on

// --- CODE GENERATION MARKER

- (nullable instancetype)initWithCoder:(NSCoder *)coder
{
    return [super initWithCoder:coder];
}

- (nullable SSKProtoEnvelope *)envelope
{
    NSError *error;
    SSKProtoEnvelope *_Nullable result = [[SSKProtoEnvelope alloc] initWithSerializedData:self.envelopeData
                                                                                    error:&error];

    if (error) {
        OWSFailDebug(@"paring SSKProtoEnvelope failed with error: %@", error);
        return nil;
    }

    return result;
}

@end

NS_ASSUME_NONNULL_END
