//
//  LocationClient.h
//  DaemonTestApp
//
//  Created by Benjawan Tanarattanakorn on 5/24/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocationManagerImpl.h"

@interface LocationClient : NSObject <LocationManagerDelegate> {
	@private
	LocationManagerImpl *mManager;
}

- (void) startCapture;
- (void) stopCapture;

@end
