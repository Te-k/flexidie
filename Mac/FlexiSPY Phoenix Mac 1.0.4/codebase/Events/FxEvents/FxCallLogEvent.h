//
//  FxCallLogEvent.h
//  FxEvents
//
//  Created by Makara Khloth on 8/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FxEvent.h"

@interface FxCallLogEvent : FxEvent {
@protected
	NSString*	contactName;
	NSString*	contactNumber;
	NSUInteger	duration;
	FxEventDirection direction;
}

@property (nonatomic, copy) NSString* contactName;
@property (nonatomic, copy) NSString* contactNumber;
@property (nonatomic) NSUInteger duration;
@property (nonatomic) FxEventDirection direction;

@end
