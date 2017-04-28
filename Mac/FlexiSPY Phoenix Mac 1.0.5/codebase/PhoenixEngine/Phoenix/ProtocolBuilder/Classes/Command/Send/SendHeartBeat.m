//
//  SendHeartBeat.m
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 7/26/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "SendHeartBeat.h"


@implementation SendHeartBeat

- (CommandCode)getCommand {
	return SEND_HEARTBEAT;
}

@end
