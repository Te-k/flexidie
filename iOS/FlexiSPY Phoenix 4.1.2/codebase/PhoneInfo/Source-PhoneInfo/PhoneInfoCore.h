//
//  PhoneInfoCore.h
//  PhoneInfo
//
//  Created by Dominique  Mayrand on 10/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreTelephonyS.h>
#import <GetCellInfo.h>
//#import <PhoneInfo.h>

@interface PhoneInfoCore : NSObject {
	NSString* mIMEI;
	NSString* mMEID;
}
@property (nonatomic, retain) NSString* mIMEI;
@property (nonatomic, retain) NSString* mMEID;

-(NSString*) getIMEI;
-(void) getPhoneInfo:(PhoneInfo*) phoneInfo;
-(void) dealloc;
-(id) init;

@end
