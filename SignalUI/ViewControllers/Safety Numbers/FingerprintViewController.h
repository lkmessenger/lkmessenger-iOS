//
// Copyright 2014 Link Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

#import <SignalUI/OWSViewControllerObjc.h>

NS_ASSUME_NONNULL_BEGIN

@class SignalServiceAddress;

@interface FingerprintViewController : OWSViewControllerObjc

+ (void)presentFromViewController:(UIViewController *)viewController address:(SignalServiceAddress *)address;

@end

NS_ASSUME_NONNULL_END
