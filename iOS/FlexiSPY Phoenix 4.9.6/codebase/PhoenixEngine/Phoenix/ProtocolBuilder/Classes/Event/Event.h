//
//  Event.h
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 8/26/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EventTypeEnum.h"

@interface Event : NSObject {
	int eventId;
	NSString *time;
}

@property (nonatomic, assign) int eventId;
@property (nonatomic, retain) NSString *time;

-(EventType)getEventType;

@end
