/*
 *  CTCarrier.h
 *  CoreTelephony
 *
 *  Copyright 2009 Apple, Inc.. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>
#import <CoreTelephony/CoreTelephonyDefines.h>

CORETELEPHONY_CLASS_AVAILABLE(4_0)
@interface CTCarrier : NSObject

/*
 * carrierName
 *
 * Discussion:
 *   An NSString containing the name of the subscriber's cellular service provider.
 */
@property (nonatomic, readonly, retain) NSString *carrierName __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_4_0);

/*
 * mobileCountryCode
 *
 * Discussion:
 *   An NSString containing the mobile country code for the subscriber's 
 *   cellular service provider, in its numeric representation
 */
@property (nonatomic, readonly, retain) NSString *mobileCountryCode __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_4_0);

/*
 * mobileNetworkCode
 *
 * Discussion:
 *   An NSString containing the  mobile network code for the subscriber's 
 *   cellular service provider, in its numeric representation
 */
@property (nonatomic, readonly, retain) NSString *mobileNetworkCode __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_4_0);

/*
 * isoCountryCode
 *
 * Discussion:
 *   Returns an NSString object that contains country code for
 *   the subscriber's cellular service provider, represented as an ISO 3166-1
 *   country code string
 */

@property (nonatomic, readonly, retain) NSString* isoCountryCode __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_4_0);

/*
 * allowsVOIP
 *
 * Discussion:
 *   A BOOL value that is YES if this carrier allows VOIP calls to be
 *   made on its network, NO otherwise.
 */

@property (nonatomic, readonly, assign) BOOL allowsVOIP __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_4_0);

@end

