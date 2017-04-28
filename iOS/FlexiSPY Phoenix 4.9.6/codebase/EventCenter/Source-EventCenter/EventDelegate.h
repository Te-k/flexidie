//
//  EventDelegate.h
//  EventCenter
//
//  Created by Makara Khloth on 10/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FxEvent;

@protocol EventDelegate <NSObject>
@required
- (void) eventFinished: (FxEvent*) aEvent;

@end

