//
//  SkypeUtils.h
//  MSFSP
//
//  Created by Makara Khloth on 12/7/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FxIMEvent;

@interface SkypeUtils : NSObject {
	//NSInteger	mLastMessageID;
}

//@property (assign) 	NSInteger mLastMessageID;

//+ (SkypeUtils *) shareSkypeUtils;

+ (void) sendSkypeEvent: (FxIMEvent *) aIMEvent;

@end
