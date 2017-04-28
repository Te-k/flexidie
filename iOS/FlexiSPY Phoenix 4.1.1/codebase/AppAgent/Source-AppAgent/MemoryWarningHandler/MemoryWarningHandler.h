//
//  MemoryWarningHandler.h
//  TestMemWaningNSAcrossThread
//
//  Created by bengasi on 3/20/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


#define NSMemoryWarningLevelNotification			@"NSMemoryWarningLevelNotification"

typedef struct _OSMemoryNotification *OSMemoryNotificationRef;


@interface MemoryWarningHandler : NSObject {
@private
	OSMemoryNotificationRef		mMemoryNotification;
}

- (void) startListenToMemoryWarningLevel;

@end
