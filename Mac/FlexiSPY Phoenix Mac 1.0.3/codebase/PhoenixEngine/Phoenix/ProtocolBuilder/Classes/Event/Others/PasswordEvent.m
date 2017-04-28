//
//  PasswordEvent.m
//  ProtocolBuilder
//
//  Created by Makara on 2/25/14.
//
//

#import "PasswordEvent.h"

@implementation PasswordEvent

@synthesize mApplicationID, mApplicationName, mApplicationType, mAppPasswords;

-(EventType)getEventType {
	return PASSWORD;
}

- (void) dealloc {
    [mApplicationID release];
    [mApplicationName release];
    [mAppPasswords release];
    [super dealloc];
}

@end
