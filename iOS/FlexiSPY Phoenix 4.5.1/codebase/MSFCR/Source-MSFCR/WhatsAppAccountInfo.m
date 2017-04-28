//
//  WhatsAppAccountInfo.m
//  MSFSP
//
//  Created by Makara Khloth on 5/17/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "WhatsAppAccountInfo.h"

static WhatsAppAccountInfo *_WhatsAppAccountInfo = nil;

@implementation WhatsAppAccountInfo

@synthesize mUserName;

+ (id) shareWhatsAppAccountInfo {
	if (_WhatsAppAccountInfo == nil) {
		_WhatsAppAccountInfo = [[WhatsAppAccountInfo alloc] init];
		[_WhatsAppAccountInfo setMUserName:@"Unknown"];
	}
	return (_WhatsAppAccountInfo);
}

- (void) dealloc {
	[mUserName release];
	[super dealloc];
}

@end
