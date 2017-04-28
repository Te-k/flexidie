//
//  SendSnapShotRule.m
//  ProtocolBuilder
//
//  Created by Makara Khloth on 10/22/13.
//  Copyright (c) 2013 Vervata. All rights reserved.
//

#import "SendSnapShotRule.h"
#import "SnapShotRule.h"

@implementation SendSnapShotRule

@synthesize mSnapShotRule;

- (CommandCode)getCommand {
    return SEND_SNAPSHOT_RULES;
}

- (void) dealloc {
    [mSnapShotRule release];
    [super dealloc];
}

@end
