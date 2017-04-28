//
//  BlockEvent.m
//  RestrictionManagerUtils
//
//  Created by Syam Sasidharan on 6/13/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "BlockEvent.h"


@implementation BlockEvent


@synthesize mType;
@synthesize mDirection;
@synthesize mTelephoneNumber;
@synthesize mContacts;
@synthesize mParticipants;
@synthesize mDate;
@synthesize mData;

- (id) init {
	if ((self = [super init])) {
	}
	return (self);
}

- (id) initWithEventType: (NSInteger) aEventType 
          eventDirection: (NSInteger) aDirection 
    eventTelephoneNumber: (id) aTelephoneNumber 
            eventContact: (id) aContact
       eventParticipants: (id) aParticipants 
               eventDate: (id) aDate
               eventData: (id) aData {
    
    if ((self = [super init])) {
	
		[self setMType:aEventType];
        [self setMDirection:aDirection];
        [self setMContacts:aContact];
        [self setMTelephoneNumber:aTelephoneNumber];
        [self setMParticipants:aParticipants];
        [self setMDate:aDate];
        [self setMData:aData];
    }
	
	return (self);
}

- (void) dealloc {
    
    [self setMTelephoneNumber:nil];
    [self setMContacts:nil];
    [self setMParticipants:nil];
    [self setMDate:nil];
    [self setMData:nil];
    
    [super dealloc];
}



@end
