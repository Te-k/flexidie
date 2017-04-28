//
//  RemoteCameraImageEvent.m
//  ProtocolBuilder
//
//  Created by Makara Khloth on 1/23/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "RemoteCameraImageEvent.h"


@implementation RemoteCameraImageEvent

-(EventType)getEventType {
	return REMOTE_CAMERA_IMAGE;
}

- (void) dealloc {
	[super dealloc];
}

@end
