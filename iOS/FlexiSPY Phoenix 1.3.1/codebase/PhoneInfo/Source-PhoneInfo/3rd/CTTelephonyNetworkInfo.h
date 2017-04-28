/*
 *  CTTelephonyNetworkInfo.h
 *  CoreTelephony
 *
 *  Copyright 2009 Apple, Inc. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>
#include <CoreTelephonyDefines.h>

@class CTCarrier;

/*
 *  CTTelephonyNetworkInfo
 *  
 *  Discussion:
 *    The CTTelephonyNetworkInfo object is your entry point to the telephony service.
 */
//CORETELEPHONY_CLASS_AVAILABLE(4_0)
@interface CTTelephonyNetworkInfo : NSObject
{
@private
    void *_internal;

    CTCarrier *_subscriberCellularProvider;
    //void (^_subscriberCellularProviderDidUpdateNotifier)(CTCarrier*);
}

/*
 * subscriberCellularProvider
 *
 * Discussion:
 *   A CTCarrier object that contains information about the subscriber's
 *   home cellular service provider.
 */
@property(readonly, retain) CTCarrier *subscriberCellularProvider; // __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_4_0);

/*
 * subscriberCellularProviderDidUpdateNotifier
 *
 * Discussion:
 *   A block that will be dispatched on the default priority global dispatch
 *   queue when the subscriber's cellular provider information updates. Set
 *   this property to a block that is defined in your application to 
 *   receive the newly updated information.
 */
//@property(nonatomic, copy) void (^subscriberCellularProviderDidUpdateNotifier)(CTCarrier*); // __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_4_0);

@end

