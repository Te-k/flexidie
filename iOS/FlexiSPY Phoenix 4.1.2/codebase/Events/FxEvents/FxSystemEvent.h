//
//  FxSystemEvent.h
//  FxEvents
//
//  Created by Makara Khloth on 9/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FxEvent.h"

@interface FxSystemEvent : FxEvent {
@protected
	NSString*			message;
	FxEventDirection	direction;
	FxSystemEventType	systemEventType;
}

@property (nonatomic, copy) NSString* message;
@property (nonatomic) FxEventDirection direction;
@property (nonatomic) FxSystemEventType systemEventType;

@end
