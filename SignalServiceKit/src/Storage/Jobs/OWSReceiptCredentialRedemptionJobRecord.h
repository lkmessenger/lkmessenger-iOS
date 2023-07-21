//
// Copyright 2021 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

#import <SignalServiceKit/SSKJobRecord.h>

NS_ASSUME_NONNULL_BEGIN

@class SDSAnyWriteTransaction;

@interface OWSReceiptCredentialRedemptionJobRecord : SSKJobRecord

@property (nonatomic, readonly) NSData *receiptCredentailRequestContext;
@property (nonatomic, readonly) NSData *receiptCredentailRequest;
@property (nonatomic, readonly, nullable) NSData *receiptCredentialPresentation;
@property (nonatomic, readonly) NSData *subscriberID;
@property (nonatomic, readonly) NSUInteger targetSubscriptionLevel;
@property (nonatomic, readonly) NSUInteger priorSubscriptionLevel;
@property (nonatomic, readonly) BOOL isBoost;
@property (nonatomic, readonly, nullable) NSDecimalNumber *amount;
@property (nonatomic, readonly, nullable) NSString *currencyCode;
@property (nonatomic, readonly) NSString *boostPaymentIntentID;

- (nullable instancetype)initWithCoder:(NSCoder *)coder NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithReceiptCredentialRequestContext:(NSData *)receiptCredentailRequestContext
                               receiptCredentailRequest:(NSData *)receiptCredentialRequest
                                           subscriberID:(NSData *)subscriberID
                                targetSubscriptionLevel:(NSUInteger)targetSubscriptionLevel
                                 priorSubscriptionLevel:(NSUInteger)priorSubscriptionLevel
                                                isBoost:(BOOL)isBoost
                                                 amount:(nullable NSDecimalNumber *)amount
                                           currencyCode:(nullable NSString *)currencyCode
                                   boostPaymentIntentID:(NSString *)boostPaymentIntentID
                                                  label:(NSString *)label NS_DESIGNATED_INITIALIZER;

- (nullable)initWithLabel:(NSString *)label NS_UNAVAILABLE;

- (instancetype)initWithGrdbId:(int64_t)grdbId
                      uniqueId:(NSString *)uniqueId
    exclusiveProcessIdentifier:(nullable NSString *)exclusiveProcessIdentifier
                  failureCount:(NSUInteger)failureCount
                         label:(NSString *)label
                        sortId:(unsigned long long)sortId
                        status:(SSKJobRecordStatus)status NS_UNAVAILABLE;

// --- CODE GENERATION MARKER

// This snippet is generated by /Scripts/sds_codegen/sds_generate.py. Do not manually edit it, instead run
// `sds_codegen.sh`.

// clang-format off

- (instancetype)initWithGrdbId:(int64_t)grdbId
                      uniqueId:(NSString *)uniqueId
      exclusiveProcessIdentifier:(nullable NSString *)exclusiveProcessIdentifier
                    failureCount:(NSUInteger)failureCount
                           label:(NSString *)label
                          sortId:(unsigned long long)sortId
                          status:(SSKJobRecordStatus)status
                          amount:(nullable NSDecimalNumber *)amount
            boostPaymentIntentID:(NSString *)boostPaymentIntentID
                    currencyCode:(nullable NSString *)currencyCode
                         isBoost:(BOOL)isBoost
          priorSubscriptionLevel:(NSUInteger)priorSubscriptionLevel
        receiptCredentailRequest:(NSData *)receiptCredentailRequest
 receiptCredentailRequestContext:(NSData *)receiptCredentailRequestContext
   receiptCredentialPresentation:(nullable NSData *)receiptCredentialPresentation
                    subscriberID:(NSData *)subscriberID
         targetSubscriptionLevel:(NSUInteger)targetSubscriptionLevel
NS_DESIGNATED_INITIALIZER NS_SWIFT_NAME(init(grdbId:uniqueId:exclusiveProcessIdentifier:failureCount:label:sortId:status:amount:boostPaymentIntentID:currencyCode:isBoost:priorSubscriptionLevel:receiptCredentailRequest:receiptCredentailRequestContext:receiptCredentialPresentation:subscriberID:targetSubscriptionLevel:));

// clang-format on

// --- CODE GENERATION MARKER

- (void)updateWithReceiptCredentialPresentation:(NSData *)receiptCredentialPresentation
                                    transaction:(SDSAnyWriteTransaction *)transaction;

@end

NS_ASSUME_NONNULL_END