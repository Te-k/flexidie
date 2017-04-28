//
//  PhoneInfoImp.h
//  PhoneInfo
//
//  Created by Dominique  Mayrand on 11/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <PhoneInfo.h>

@class CTCarrier;

/*
static const NSString * kIMEI = @"IMEI";

@protocol PhoneInfoRequest <NSObject>

- (void) IMEIDidReceive: (NSDictionary *) aInfo;

@end
 */


@interface PhoneInfoImp : NSObject <PhoneInfo> {
@private	
	NSString* mIMEI;
	NSString* mMEID;
}

/*
@property (nonatomic, assign) id mPhoneInfoDelegate;

- (void) getIMEIAsynchronouslyForThread: (NSThread *) aCallbackThread;
*/
@end
