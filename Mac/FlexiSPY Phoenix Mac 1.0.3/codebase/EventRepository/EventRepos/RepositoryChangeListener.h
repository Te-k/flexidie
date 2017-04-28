//
//  RepositoryChangeListener.h
//  EventRepos
//
//  Created by Makara Khloth on 9/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FxEventEnums.h"

@class FxEvent;

@protocol RepositoryChangeListener <NSObject>
@required
- (void) eventTypeAdded: (FxEventType) aEventType;
- (void) panicEventAdded;
- (void) maxEventReached;
- (void) systemEventAdded;

@optional
- (void) eventAdded: (FxEvent *) aEvent;
@end

