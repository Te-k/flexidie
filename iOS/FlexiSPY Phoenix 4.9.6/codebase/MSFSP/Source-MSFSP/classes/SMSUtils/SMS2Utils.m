//
//  SMS2Utils.m
//  MSFSP
//
//  Created by Makara Khloth on 2/12/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SMS2Utils.h"

static SMS2Utils *_SMS2Utils = nil;

@implementation SMS2Utils

@synthesize mSmsBadge;

+ (id) sharedSMS2Utils {
	if (_SMS2Utils == nil) {
		_SMS2Utils = [[SMS2Utils alloc] init];
	}
	return (_SMS2Utils);
}

@end
