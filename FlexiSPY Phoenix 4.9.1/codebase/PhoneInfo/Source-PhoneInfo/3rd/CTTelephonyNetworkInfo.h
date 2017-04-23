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

// iOS 7, before use must call respondsToSelector: method
@property(retain) NSString *cachedCellId; // @synthesize cachedCellId=_cachedCellId;
@property(retain) NSDictionary *cachedSignalStrength; // @synthesize cachedSignalStrength=_cachedSignalStrength;
@property(retain) NSString *cachedCurrentRadioAccessTechnology; // @synthesize cachedCurrentRadioAccessTechnology=_cachedCurrentRadioAccessTechnology;
@property(retain, nonatomic) NSString *cellId;
@property(readonly, nonatomic) NSString *currentRadioAccessTechnology;
- (id)signalStrength;

@end

