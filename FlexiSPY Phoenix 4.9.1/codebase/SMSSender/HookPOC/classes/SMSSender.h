//
//  SMSSender.h
//  HookPOC
//
//  Created by Makara Khloth on 3/8/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IMServiceImpl, IMAccount;

@interface SMSSender : NSObject {
@private
	IMServiceImpl	*mIMSMSService;
	IMAccount		*mIMAccount;
	
	//
	NSTimer		*mSMSSendingTimer;
}

+ (id) sharedSMSSender;
@end
