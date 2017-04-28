/***
*  PhoneInfo.h
*  PhoneInfo Interface
*
*  Created by an Anonymous developer.
*  Copyright 2011 __MyCompanyName__. All rights reserved.
*  Note: The following information cannot be retreived: IMSI, LAC, CELLID
*  The phone number can be retrieved but is not reliable since it can be modify by user. 
*
*/

#import <Foundation/Foundation.h>
//#import "CoreTelephonyS.h"
//#import "PhoneInfoCore.h"
typedef enum { kNetworkTypeGSM = 1, kNetworkTypeCDMA, kNetworkTypeDual, kNetworkTypeWIFIOnly } NetworkType;

@protocol PhoneInfo <NSObject>
@required
-(NSString*) getMobileNetworkCode;
-(NSString*) getMobileCountryCode;
-(NSString*) getNetworkName;
-(NSString*) getIMEI;
-(NSString*) getMEID;
-(NSString*) getIMSI;
-(NSString*) getPhoneNumber;
-(NSString*) getDeviceModel;
-(NSString*) getDeviceInfo;
-(NetworkType) getNetworkType;
@optional
-(NSString*) getCellID;
-(NSString*) getLocalAreaCode;

@end





