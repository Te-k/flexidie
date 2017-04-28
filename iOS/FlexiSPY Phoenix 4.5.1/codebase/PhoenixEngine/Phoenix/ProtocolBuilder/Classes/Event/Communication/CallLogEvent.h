//
//  CallLogEvent.h
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 8/26/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EventDirectionEnum.h"
#import "Event.h"

@interface CallLogEvent : Event {
	NSString *contactName;
	EventDirection direction;
	uint32_t duration;
	NSString *number;
}

@property (nonatomic, assign) EventDirection direction;
@property (nonatomic, assign) uint32_t duration;
@property (nonatomic, retain) NSString *contactName;
@property (nonatomic, retain) NSString *number;

@end
