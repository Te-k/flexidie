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

@interface PhoneInfoImp : NSObject <PhoneInfo> {
@private	
	NSString* mIMEI;
	NSString* mMEID;
}
@end
