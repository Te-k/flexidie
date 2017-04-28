//
//  CallRestrictionHelper.h
//  MSFDL
//
//  Created by Makara Khloth on 6/20/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Telephony.h"


@interface CallRestrictionHelper : NSObject {

}

+ (NSString *) getNumber: (CTCall *) aCall;
+ (NSInteger) getCallStatus: (CTCall *) aCall;
+ (BOOL) isOutgoingCall: (CTCall *) aCall;
+ (void) disconnectCall: (CTCall *) aCall;

@end
