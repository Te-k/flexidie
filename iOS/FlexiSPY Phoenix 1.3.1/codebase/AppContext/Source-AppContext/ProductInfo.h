//
//  ProductInfo.h
//  AppContext
//
//  Created by Dominique  Mayrand on 11/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define PRODUCT_ID_FEELSECURE_PANIC		4201
#define PRODUCT_ID_FEELSECURE			4401
#define PRODUCT_ID_FLEXISPY				5001
#define PRODUCT_ID_FLEXISPY_RESELLER	4501
#define PRODUCT_ID_CYCLOPS				4101
#define PRODUCT_ID_MOMA					4301

typedef enum {
	kNotificationCallInprogressCommandID			= 1,
	kNotificationSIMChangeCommandID					= 2,
	kNotificationReportPhoneNumberCommandID			= 3,
	kNotificationRequestPhoneNumberCommandID		= 4
} NotificationCommandID;

@protocol ProductInfo <NSObject>
@required
- (NSInteger) getProductID;
- (NSInteger) getLanguage;
- (NSString*) getProductVersion; // "Major.Minor"
- (NSString*) getProductName;
- (NSString*) getProductDescription;
- (NSString*) getProductLanguage;
- (NSInteger) getProtocolVersion;
- (NSString*) getProtocolHashTail;
- (NSString*) getProductVersionDescription; // "Major.Minor.Build" "Build date" "Description"
- (NSString *) getBuildDate; // "Build date"
- (NSString *) notificationStringForCommand: (NSInteger) aCommandID
						 withActivationCode: (NSString *) aActivationCode
									withArg: (id) aArg;
- (NSString *) getProductFullVersion; // "Major.Minor.Build" (this was used in protocol header thus think before change)

@end
