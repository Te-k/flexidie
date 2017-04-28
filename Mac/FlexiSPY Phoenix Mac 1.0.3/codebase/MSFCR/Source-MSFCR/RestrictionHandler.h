
//
//  RestrictionHandler.h
//  MSFCR
//
//  Created by Syam Sasidharan on 6/19/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface RestrictionHandler : NSObject {

}

+ (id) sharedRestrictionHandler;

+ (BOOL) blockForEvent: (id) aEvent;

+ (void) showBlockMessage;
+ (void) showMessage: (NSString *) aMessage;

+ (NSInteger) lastBlockCause;

+ (NSDate *) blockEventDate;

@end
