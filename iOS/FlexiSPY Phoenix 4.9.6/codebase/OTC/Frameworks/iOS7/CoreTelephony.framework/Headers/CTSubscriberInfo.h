/*
 *  CTSubscriberInfo.h
 *  CFTelephony
 *
 *  Copyright 2012 Apple, Inc. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>
#import <CoreTelephony/CoreTelephonyDefines.h>

#import "CTSubscriber.h"

CORETELEPHONY_CLASS_AVAILABLE(6_0)
@interface CTSubscriberInfo : NSObject

+ (CTSubscriber*) subscriber;

@end
