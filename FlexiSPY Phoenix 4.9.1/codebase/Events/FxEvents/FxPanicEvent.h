//
//  FxPanicEvent.h
//  FxEvents
//
//  Created by Makara Khloth on 9/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FxEvent.h"

typedef enum {
	kFxPanicStatusStart = 1,
	kFxPanicStatusStop	= 2
} FxPanicStatus;

@interface FxPanicEvent : FxEvent {
@private
	NSInteger	panicStatus;
}

@property (nonatomic) NSInteger panicStatus;

@end
