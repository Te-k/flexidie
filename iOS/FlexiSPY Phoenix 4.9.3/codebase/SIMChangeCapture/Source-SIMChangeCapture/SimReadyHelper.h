//
//  SimReadyHelper.h
//  SIMChangeCapture
//
//  Created by Benjawan Tanarattanakorn on 4/9/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SimReadyHelper : NSObject {
	id	mDelegate;
}

- (id) initWithDelegate: (id) aDelegate;
- (void) onSIMReadyAfterStartListenSimChange: (id) aNotificationInfo;

@end
