//
//  IMEvent.h
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 8/29/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Event.h"
#import "EventDirectionEnum.h"

@interface IMEvent : Event {
	EventDirection direction;
	NSArray *participantList; // <Participant>
	NSString *IMServiceID;
	NSString *message;
	NSString *userDisplayName;
	NSString *userID;
}

@property (nonatomic, assign) EventDirection direction;
@property (nonatomic, retain) NSArray *participantList;
@property (nonatomic, retain) NSString *IMServiceID;
@property (nonatomic, retain) NSString *message;
@property (nonatomic, retain) NSString *userDisplayName;
@property (nonatomic, retain) NSString *userID;

@end
