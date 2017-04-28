//
//  SpyCallDisconnectDelegate.h
//  MSSPC
//
//  Created by Makara Khloth on 3/20/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FxCall;

@protocol SpyCallDisconnectDelegate <NSObject>

- (void) spyCallDisconnecting: (FxCall *) aSpyCall;
- (void) spyCallDidCompletelyDisconnected: (FxCall *) aSpyCall;

@end
